--           LNRA-8
--
--              n
--      o   g a    s m
--        r       i     i c
--                     z
--       y   t h   s       r
--     s   n     e   i   e
--
-- LYRA-8 synth by SOMA Labs
-- LIRA-8 pd patch Mike Moreno
-- LNRA-8 norns wrapper xmacex

DEBUG = false

UI = require('ui')
MU = require('musicutil')

pd_osc      = {"localhost", 10121}
engine_boot = _path.this.lib.."lnra-8.sh"
midi_dev    = nil

local WIDTH   = 128
local HEIGHT  = 64
local shifted = false

tune_uis = {}
midi_ui = {
   [60] = 'sensor-1',
   [61] = 'source-12',
   [62] = 'sensor-2',
   [63] = 'source-34',
   [64] = 'sensor-3',
   [65] = 'sensor-4',
   [66] = 'source-56',
   [67] = 'sensor-5',
   [68] = 'source-78',
   [69] = 'sensor-6',
   [71] = 'sensor-7',
   [72] = 'sensor-8'
}
lyra_variations = {"y", "i", "n"}

-- # Lifecycle.

function init()
   -- Initialize everything.
   start_pd()
   init_params()
   init_ui()

   -- Get an UI loop going.
   clock.run(function()
	 while true do
	    clock.sleep(1/15)
	    redraw()
	 end
   end)
end

function rerun()
   cleanup()
end

function cleanup()
   stop_pd()
end

-- # Pd process management. Crude lol.

function start_pd()
   if not DEBUG then
      os.execute(engine_boot)
   end
end

function stop_pd()
   if not DEBUG then
      os.execute("jack_disconnect pure_data:output_1 crone:input_1")
      os.execute("jack_disconnect pure_data:output_2 crone:input_2")
      os.execute("killall pd")
   end
end

-- # Parameter setup.

function init_params()
   params:add_option('midi-dev', "midi dev", get_midi_device_names())
   params:set_action('midi-dev', function(val)
			midi_dev = midi.connect(val)
			midi_dev.event = midi_handler
   end)
   params:add_number('midi-ch', "midi channel", 1,  16, 1)

   -- 1234
   params:add_group('1234', "1 2 3 4", 10)

   params:add_taper('hold-1234', 'hold', 0, 127, 60)
   params:set_action('hold-1234', function(freq)
			osc.send(pd_osc, "/hold-1234", {freq})
			hold_1234_ui:set_value(freq)
   end)
   params:set('hold-1234', params:get('hold-1234'))

   params:add_taper('pitch-1234', 'pitch', 0, 127, 30)
   params:set_action('pitch-1234', function(freq)
			osc.send(pd_osc, "/pitch-1234", {freq})
			pitch_1234_ui:set_value(freq)
   end)
   params:set('pitch-1234', params:get('pitch-1234'))

   -- 12
   params:add_separator("1 2")
   params:add_option('source-12', 'source', {'3 4', 'off', 'lfo'}, 1)
   params:set_action('source-12', function(src)
			osc.send(pd_osc, "/source-12", {src-1})
			-- source_12_ui:set_value(src-1)
   end)
   params:set('source-12', params:get('source-12'))

   params:add_taper('mod-12', ' ↳mod', 0, 127, 60)
   params:set_action('mod-12', function(modulation)
			osc.send(pd_osc, "/mod-12", {modulation})
			mod_12_ui:set_value(modulation)
   end)
   params:set('mod-12', params:get('mod-12'))

   params:add_taper('sharp-12', 'sharp', 0, 127, 60)
   params:set_action('sharp-12', function(sharp)
			osc.send(pd_osc, "/sharp-12", {sharp})
			sharp_12_ui:set_value(sharp)
   end)
   params:set('sharp-12', params:get('sharp-12'))

   -- 34
   params:add_separator("3 4")
   params:add_option('source-34', 'source', {'1 2', 'off', 'lfo'}, 1)
   params:set_action('source-34', function(src)
			osc.send(pd_osc, "/source-34", {src-1})
			-- source_34_ui:set_value(src-1)
   end)
   params:set('source-34', params:get('source-34'))

   params:add_taper('mod-34', ' ↳mod', 0, 127, 60)
   params:set_action('mod-34', function(modulation)
			osc.send(pd_osc, "/mod-34", {modulation})
			mod_34_ui:set_value(modulation)
   end)
   params:set('mod-34', params:get('mod-34'))

   params:add_taper('sharp-34', 'sharp', 0, 127, 60)
   params:set_action('sharp-34', function(sharp)
			osc.send(pd_osc, "/sharp-34", {sharp})
			sharp_34_ui:set_value(sharp)
   end)
   params:set('sharp-34', params:get('sharp-34'))

   -- 5678
   params:add_group('5678', "5 6 7 8", 10)

   params:add_taper('hold-5678', 'hold', 0, 127, 10)
   params:set_action('hold-5678', function(freq)
			osc.send(pd_osc, "/hold-5678", {freq})
			hold_5678_ui:set_value(freq)
   end)
   params:set('hold-5678', params:get('hold-5678'))

   params:add_taper('pitch-5678', 'pitch', 0, 127, 80)
   params:set_action('pitch-5678', function(freq)
			osc.send(pd_osc, "/pitch-5678", {freq})
			pitch_5678_ui:set_value(freq)
   end)
   params:set('pitch-5678', params:get('pitch-5678'))

   -- 56
   params:add_separator("5 6")
   params:add_option('source-56', 'source', {'7 8', 'off', 'lfo'}, 1)
   params:set_action('source-56', function(src)
			osc.send(pd_osc, "/source-56", {src-1})
			-- source_56_ui:set_value(src-1)
   end)
   params:set('source-56', params:get('source-56'))

   params:add_taper('mod-56', ' ↳mod', 0, 127, 60)
   params:set_action('mod-56', function(modulation)
			osc.send(pd_osc, "/mod-56", {modulation})
			mod_56_ui:set_value(modulation)
   end)
   params:set('mod-56', params:get('mod-56'))

   params:add_taper('sharp-56', 'sharp', 0, 127, 60)
   params:set_action('sharp-56', function(sharp)
			osc.send(pd_osc, "/sharp-56", {sharp})
			sharp_56_ui:set_value(sharp)
   end)
   params:set('sharp-56', params:get('sharp-56'))

   -- 78
   params:add_separator("7 8")

   params:add_option('source-78', 'source', {'5 6', 'off', 'lfo'}, 1)
   params:set_action('source-78', function(src)
			osc.send(pd_osc, "/source-78", {src-1})
			-- source_78_ui:set_value(src-1)
   end)
   params:set('source-78', params:get('source-34'))

   params:add_taper('mod-78', ' ↳mod', 0, 127, 60)
   params:set_action('mod-78', function(modulation)
			osc.send(pd_osc, "/mod-78", {modulation})
			mod_78_ui:set_value(modulation)
   end)
   params:set('mod-78', params:get('mod-78'))

   params:add_taper('sharp-78', 'sharp', 0, 127, 60)
   params:set_action('sharp-78', function(sharp)
			osc.send(pd_osc, "/sharp-78", {sharp})
			sharp_78_ui:set_value(sharp)
   end)
   params:set('sharp-78', params:get('sharp-78'))

   -- Oscillators
   for i = 1,8 do
      -- Sensor
      params:add_binary('sensor-'..i, 'sensor '..i, "toggle")
      params:set_action('sensor-'..i, function(sensor)
			   osc.send(pd_osc, "/sensor-"..i, {sensor})
      end)

      -- Tune
      params:add_taper('tune-'..i, ' ↳tune '..i, 0, 127, math.random(127))
      params:set_action('tune-'..i, function(tune)
			   osc.send(pd_osc, "/tune-"..i, {tune})
			   tune_uis[i]:set_value(tune)
      end)
      params:set('tune-'..i, params:get('tune-'..i))
   end

   -- The things in the middle of the panel
   params:add_binary('total-fb', 'total fb', "toggle", math.random(2)-1)
   params:set_action('total-fb', function(on)
			osc.send(pd_osc, "/total-fb", {on})
   end)

   params:add_binary('vibrato', 'vibrato', "toggle", math.random(2)-1)
   params:set_action('vibrato', function(on)
			osc.send(pd_osc, "/vibrato", {on})
   end)

   params:add_option('switch', 'fm structure', {'34 > 56', '78 > 12'})
   params:set_action('switch', function(val)
			osc.send(pd_osc, "/switch", {val-1})
   end)

   -- Hyper LFO
   params:add_group('hyperlfo', "hyper lfo", 4)
   params:add_taper('f-a', 'freq a', 0, 127, math.random(127))
   params:set_action('f-a', function(val)
			if DEBUG then print("f-a: "..val) end
			osc.send(pd_osc, "/f-a", {val})
			-- f_a_ui:set_value(val)
   end)
   params:set('f-a', params:get('f-a'))

   params:add_taper('f-b', 'freq b', 0, 127, math.random(127))
   params:set_action('f-b', function(val)
			if DEBUG then print("f-b: "..val) end
			osc.send(pd_osc, "/f-b", {val})
			-- f_b_ui:set_value(val)
   end)
   params:set('f-b', params:get('f-b'))

   params:add_option('andor', 'and/or', {'and', 'or'}, 1)
   params:set_action('andor', function(val)
			if DEBUG then print("andor: "..val-1) end
			osc.send(pd_osc, "/andor", {val-1})
   end)

   params:add_binary('link', 'link', "toggle", math.random(2)-1)
   params:set_action('link', function(on)
			if DEBUG then print("link: "..on-1) end
			osc.send(pd_osc, "/link", {on-1})
   end)

   -- Mod-delay
   params:add_group('mod-delay', "mod delay", 8)

   params:add_taper('mod-1', "mod 1", 0, 127)
   params:set_action('mod-1', function(val)
			if DEBUG then print("mod-1: "..val) end
			osc.send(pd_osc, "/mod-1", {val})
			-- mod_1_ui:set_value(val)
   end)

   params:add_taper('time-1', "time 1", 0, 127)
   params:set_action('time-1', function(val)
			if DEBUG then print("time-1: "..val) end
			osc.send(pd_osc, "/time-1", {val})
			-- time_1_ui:set_value(val)
   end)

   params:add_taper('mod-2', "mod 2", 0, 127)
   params:set_action('mod-2', function(val)
			if DEBUG then print("mod-2: "..val) end
			osc.send(pd_osc, "/mod-2", {val})
			-- mod_2_ui:set_value(val)
   end)

   params:add_taper('time-2', "time 2", 0, 127)
   params:set_action('time-2', function(val)
			if DEBUG then print("time-2: "..val) end
			osc.send(pd_osc, "/time-2", {val})
			-- time_2_ui:set_value(val)
   end)

   params:add_option('lfo-wav', "lfo wav", {"tri", "sqr"})
   params:set_action('lfo-wav', function(val)
			if DEBUG then print("lfo-wav: "..val-1) end
			osc.send(pd_osc, "/lfo-wav", {val-1})
   end) -- TODO

   params:add_taper('feedback', "feedback", 0, 127)
   params:set_action('feedback', function(val)
			if DEBUG then print("feedback: "..val) end
			osc.send(pd_osc, "/feedback", {val})
			-- feedback_ui:set_value(val)
   end)

   params:add_option('del-mod', "del mod", {"self", "off", "lfo"})
   params:set_action('del-mod', function(val) end) -- TODO∑

   params:add_taper('del-mix', "mix", 0, 127)
   params:set_action('del-mix', function(val)
			if DEBUG then print("del-mix: "..val) end
			osc.send(pd_osc, "/del-mix", {val})
			-- del_mix_ui:set_value(val)
   end)

   -- Distortion
   params:add_group('distortion', "distortion", 2)

   params:add_taper('dst-drv', "drv", 0, 127)
   params:set_action('dst-drv', function(val)
			if DEBUG then print("dst-drv: "..val) end
			osc.send(pd_osc, "/dst-drv", {val})
			-- dst_drv_ui:set_value(val)
   end)

   params:add_taper('dst-mix', "mix", 0, 127)
   params:set_action('dst-mix', function(val)
			if DEBUG then print("dst-mix: "..val) end
			osc.send(pd_osc, "/dst-mix", {val})
			-- dst_mix_ui:set_value(val)
   end)

   -- params:add_taper('dst-vol', "vol (disabled, use norns vol)", 0, 127)
   -- params:set_action('dst-vol', function(val)
   -- 			if DEBUG then print("dst-vol: "..val) end
   -- 			print("use norns volume instead")
   -- 			-- osc.send(pd_osc, "/dst-vol", {val})
   -- 			-- dst_vol_ui:set_value(val)
   end)
end

-- # Build UI

function init_ui()
   -- 1234
   hold_1234_ui  = UI.Dial.new(WIDTH/8*2-7, 7, 15, params:get("hold-1234"), 0, 127)
   pitch_1234_ui = UI.Dial.new(WIDTH/8*2-7, 7+15, 15, params:get("pitch-1234"), 0, 127)
   -- 5678
   hold_5678_ui  = UI.Dial.new(WIDTH/8*6-7, 7, 15, params:get("hold-5678"), 0, 127)
   pitch_5678_ui = UI.Dial.new(WIDTH/8*6-7, 7+15, 15, params:get("pitch-5678"), 0, 127)

   for i=1,8 do
      local tune_ui = UI.Dial.new(WIDTH/8*i-13, HEIGHT-18, 10, params:get('tune-'..i), 0, 127)
      table.insert(tune_uis, tune_ui)
   end

   for _, dial in pairs{hold_1234_ui, pitch_1234_ui,
			hold_5678_ui, pitch_5678_ui} do
      remove_title(dial)
   end
   for _,tune_ui in pairs(tune_uis) do
      remove_title(tune_ui)
   end

   mod_12_ui = UI.Slider.new(WIDTH/8/2-8, HEIGHT/2+8, WIDTH/4, 1, params:get('mod-12'), 0, 127, nil, 'right')
   sharp_12_ui = UI.Slider.new(WIDTH/8/2-8, HEIGHT/2+10, WIDTH/4, 1, params:get('sharp-12'), 0, 127, nil, 'right')

   mod_34_ui = UI.Slider.new(WIDTH/8*2, HEIGHT/2+8, WIDTH/4, 1, params:get('mod-34'), 0, 127, nil, 'right')
   sharp_34_ui = UI.Slider.new(WIDTH/8*2, HEIGHT/2+10, WIDTH/4, 1, params:get('sharp-34'), 0, 127, nil, 'right')

   mod_56_ui = UI.Slider.new(WIDTH/8*4, HEIGHT/2+8, WIDTH/4, 1, params:get('mod-56'), 0, 127, nil, 'right')
   sharp_56_ui = UI.Slider.new(WIDTH/8*4, HEIGHT/2+10, WIDTH/4, 1, params:get('sharp-56'), 0, 127, nil, 'right')

   mod_78_ui = UI.Slider.new(WIDTH/8*6, HEIGHT/2+8, WIDTH/4, 1, params:get('mod-78'), 0, 127, nil, 'right')
   sharp_78_ui = UI.Slider.new(WIDTH/8*6, HEIGHT/2+10, WIDTH/4, 1, params:get('sharp-78'), 0, 127, nil, 'right')
end

function remove_title(dial)
   dial.title = ""
end


-- # Interactions.

-- Respond to encoders.
function enc(n, d)
   if n == 1 then
      print("E1 not implemented")
   elseif n == 2 then
      if shifted then
	 params:delta('pitch-1234', d)
      else
	 params:delta('hold-1234', d)
      end
   elseif n == 3 then
      if shifted then
	 params:delta('pitch-5678', d)
      else
	 params:delta('hold-5678', d)
      end
   end
end

-- K1 pressed. It's the shift.
function key(button, pressed)
   -- NB. 0 is true in Lua, not false
   if button == 1 then
      if pressed == 1 then
	 shifted = true
      elseif pressed == 0 then
	 shifted = false
      end
   end
end

-- # Drawing

-- Redraw the screen.
function redraw()
   screen.clear()

   -- the two sides
   hold_1234_ui:redraw()
   pitch_1234_ui:redraw()
   hold_5678_ui:redraw()
   pitch_5678_ui:redraw()

   -- the individual oscillators / tune
   for _,tune_ui in pairs(tune_uis) do
      tune_ui:redraw()
   end

   -- the individual oscillators / sensors
   for i=1,8 do
      screen.circle(WIDTH/8*i-8, HEIGHT-3, 3)
      if params:get('sensor-'..i) == 1 then
	 screen.fill()
      else
	 screen.stroke()
      end
   end

   -- the mods for each pair / source
   for i,oscs in pairs{'12', '34', '56', '78'} do
      for s=1,3 do
	 screen.pixel(WIDTH/8*i*2-WIDTH/8 -6 + s*3, HEIGHT/2+5)
	 if params:get('source-'..oscs) == s then
	    screen.level(10)
	 else
	    screen.level(1)
	 end
	 screen.stroke()
      end
   end

   -- the mods for each pair / mod depth
   mod_12_ui:redraw()
   mod_34_ui:redraw()
   mod_56_ui:redraw()
   mod_78_ui:redraw()

   -- the sharpness for each pair
   sharp_12_ui:redraw()
   sharp_34_ui:redraw()
   sharp_56_ui:redraw()
   sharp_78_ui:redraw()

   -- a bit of logo
   screen.level(5)
   screen.move(WIDTH/2, HEIGHT/2-4)
   screen.font_face( 8+math.random(4))
   screen.font_size(12+math.random(4))
   screen.text_center("l"..lyra_variations[math.random(#lyra_variations)].."ra-8")
   screen.stroke()

   screen.update()
end

function midi_handler(data)
   local msg = midi.to_msg(data)
   if msg.ch == params:get('midi-ch') then
      if msg.type == "note_on" or msg.type == "note_off" then
	 -- tab.print(msg)
	 local par = midi_ui[msg.note]
	 if par:find("^sensor") then
	    if msg.type == "note_on" then
	       params:set(par, 1)
	    elseif msg.type == "note_off" then
	       params:set(par, 0)
	    end
	 elseif par:find("^source") then
	    if msg.type == "note_on" then
	       params:set(par, ((params:get(par) + 1) % 3) + 1)
	    end
	 end
      end
   end
end

function get_midi_device_names()
    local names = {}
    for _, v in pairs(midi.vports) do
        if v.connected then
            table.insert(names, v.name)
        end
    end
    return names
end

-- Local Variables:
-- flycheck-luacheck-standards: ("lua51" "norns")
-- End:
