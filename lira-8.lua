--           LIRA-8
--       ^ ^  o o ^ ^ o o
--       o o o o o o o
--          o  ^ ^  o
--        ^ o ^ ^ ^ o ^
--       o o o o o o o o
--       O O O O O O O O
--       8 8 8 8 8 8 8 8
--

-- First, a bash script starts a headless Pd with the Lira-8 Pd patch.
-- Second, the patch listens to UDP OSC messages in port 10121.
--
-- The following addresses are recognized:
--
--     /hold-1234 f   Hold 1, 2, 3 and 4
--     /pitch-1234 f  Hold 1, 2, 3 and 4
--     /hold-5678 f   Hold 5, 6, 7 and 8
--     /hold-5678 f   Hold 5, 6, 7 and 8
--
-- Finally when the norns script exits, all running Pd processes are killed (crude!)

DEBUG = false

UI = require('ui')

pd_osc      = {"localhost", 10121}
engine_boot = _path.this.lib.."lira-8.sh"

local WIDTH   = 128
local HEIGHT  = 64
local shifted = false

tune_uis = {}

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
   -- 1234
   params:add_group('1234', "1234", 8)
   params:add_number('hold-1234', 'hold 1234', 0, 127, 60)
   params:set_action('hold-1234', function(freq)
			osc.send(pd_osc, "/hold-1234", {freq})
			hold_1234_ui:set_value(freq)
   end)
   params:set('hold-1234', params:get('hold-1234'))

   params:add_number('pitch-1234', 'pitch 1234', 0, 127, 30)
   params:set_action('pitch-1234', function(freq)
			osc.send(pd_osc, "/pitch-1234", {freq})
			pitch_1234_ui:set_value(freq)
   end)
   params:set('pitch-1234', params:get('pitch-1234'))

   -- 12
   params:add_option('source-12', 'source 12', {'3 and 4', 'off', 'lfo-cv'}, 1)
   params:set_action('source-12', function(src)
			osc.send(pd_osc, "/source-12", {src-1})
			-- source_12_ui:set_value(src-1)
   end)
   params:set('source-12', params:get('source-12'))

   params:add_number('mod-12', 'mod 12', 0, 127, 60)
   params:set_action('mod-12', function(modulation)
			osc.send(pd_osc, "/mod-12", {modulation})
			mod_12_ui:set_value(modulation)
   end)
   params:set('mod-12', params:get('mod-12'))

   params:add_number('sharp-12', 'sharp 12', 0, 127, 60)
   params:set_action('sharp-12', function(sharp)
			osc.send(pd_osc, "/sharp-12", {sharp})
			sharp_12_ui:set_value(sharp)
   end)
   params:set('sharp-12', params:get('sharp-12'))

   -- 34
   params:add_option('source-34', 'source 34', {'1 and 2', 'off', 'lfo-cv'}, 1)
   params:set_action('source-34', function(src)
			osc.send(pd_osc, "/source-34", {src-1})
			-- source_34_ui:set_value(src-1)
   end)
   params:set('source-34', params:get('source-34'))

   params:add_number('mod-34', 'mod 34', 0, 127, 60)
   params:set_action('mod-34', function(modulation)
			osc.send(pd_osc, "/mod-34", {modulation})
			mod_34_ui:set_value(modulation)
   end)
   params:set('mod-34', params:get('mod-34'))

   params:add_number('sharp-34', 'sharp 34', 0, 127, 60)
   params:set_action('sharp-34', function(sharp)
			osc.send(pd_osc, "/sharp-34", {sharp})
			sharp_34_ui:set_value(sharp)
   end)
   params:set('sharp-34', params:get('sharp-34'))

   -- 5678
   params:add_group('5678', "5678", 8)
   params:add_number('hold-5678', 'hold 5678', 0, 127, 10)
   params:set_action('hold-5678', function(freq)
			osc.send(pd_osc, "/hold-5678", {freq})
			hold_5678_ui:set_value(freq)
   end)
   params:set('hold-5678', params:get('hold-5678'))

   params:add_number('pitch-5678', 'pitch 5678', 0, 127, 80)
   params:set_action('pitch-5678', function(freq)
			osc.send(pd_osc, "/pitch-5678", {freq})
			pitch_5678_ui:set_value(freq)
   end)
   params:set('pitch-5678', params:get('pitch-5678'))

   -- 56
   params:add_option('source-56', 'source 56', {'7 and 8', 'off', 'lfo-cv'}, 1)
   params:set_action('source-56', function(src)
			osc.send(pd_osc, "/source-56", {src-1})
			-- source_56_ui:set_value(src-1)
   end)
   params:set('source-56', params:get('source-56'))

   params:add_number('mod-56', 'mod 56', 0, 127, 60)
   params:set_action('mod-56', function(modulation)
			osc.send(pd_osc, "/mod-56", {modulation})
			mod_56_ui:set_value(modulation)
   end)
   params:set('mod-56', params:get('mod-56'))

   params:add_number('sharp-56', 'sharp 56', 0, 127, 60)
   params:set_action('sharp-56', function(sharp)
			osc.send(pd_osc, "/sharp-56", {sharp})
			sharp_56_ui:set_value(sharp)
   end)
   params:set('sharp-56', params:get('sharp-56'))

   -- 78
   params:add_option('source-78', 'source 78', {'5 and 6', 'off', 'lfo-cv'}, 1)
   params:set_action('source-78', function(src)
			osc.send(pd_osc, "/source-78", {src-1})
			-- source_78_ui:set_value(src-1)
   end)
   params:set('source-78', params:get('source-34'))

   params:add_number('mod-78', 'mod 78', 0, 127, 60)
   params:set_action('mod-78', function(modulation)
			osc.send(pd_osc, "/mod-78", {modulation})
			mod_78_ui:set_value(modulation)
   end)
   params:set('mod-78', params:get('mod-78'))

   params:add_number('sharp-78', 'sharp 78', 0, 127, 60)
   params:set_action('sharp-78', function(sharp)
			osc.send(pd_osc, "/sharp-78", {sharp})
			sharp_78_ui:set_value(sharp)
   end)
   params:set('sharp-78', params:get('sharp-78'))

   -- Oscillators
   for i = 1,8 do
      -- Tune
      params:add_number('tune-'..i, 'tune '..i, 0, 127, math.random(127))
      params:set_action('tune-'..i, function(tune)
			   osc.send(pd_osc, "/tune-"..i, {tune})
			   tune_uis[1]:set_value(tune)
      end)
      params:set('tune-'..i, params:get('tune-'..i))

      -- Sensor
      params:add_binary('sensor-'..i, 'sensor '..i, "toggle")
      params:set_action('sensor-'..i, function(sensor)
			   osc.send(pd_osc, "/sensor-"..i, {sensor})
      end)
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

   params:add_option('switch', 'switch', {'34 > 56', '78 > 12'})
   params:set_action('switch', function(val)
			osc.send(pd_osc, "/switch", {val-1})
   end)

   -- Hyper LFO
   params:add_group('hyperlfo', "hyper lfo", 4)
   params:add_number('f-a', 'f-a', 0, 127, math.random(127))
   params:set_action('f-a', function(val)
			if DEBUG then print("f-a: "..val) end
			osc.send(pd_osc, "/f-a", {val})
			-- f_a_ui:set_value(val)
   end)
   params:set('f-a', params:get('f-a'))

   params:add_number('f-b', 'f-b', 0, 127, math.random(127))
   params:set_action('f-b', function(val)
			if DEBUG then print("f-b: "..val) end
			osc.send(pd_osc, "/f-b", {val})
			-- f_b_ui:set_value(val)
   end)
   params:set('f-b', params:get('f-b'))

   params:add_option('andor', 'and/or', {'and', 'or'}, 1)
   params:set_action('andor', function(val)
			if DEBUG then print("andor: "..val-1) end
			osc.send(pd_osc, "/switch", {val-1})
   end)

   params:add_binary('link', 'link', "toggle", math.random(2)-1)
   params:set_action('link', function(on)
			if DEBUG then print("link: "..on-1) end
			osc.send(pd_osc, "/link", {on-1})
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
   screen.level(math.random(10))
   hold_1234_ui:redraw()
   pitch_1234_ui:redraw()
   hold_5678_ui:redraw()
   pitch_5678_ui:redraw()
   for _,tune_ui in pairs(tune_uis) do
      tune_ui:redraw()
   end
   for i=1,8 do
      screen.circle(WIDTH/8*i-8, HEIGHT-3, 3)
      if params:get('sensor-'..i) == 1 then
	 screen.fill()
      else
	 screen.stroke()
      end
   end

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

   mod_12_ui:redraw()
   sharp_12_ui:redraw()
   mod_34_ui:redraw()
   sharp_34_ui:redraw()
   mod_56_ui:redraw()
   sharp_56_ui:redraw()
   mod_78_ui:redraw()
   sharp_78_ui:redraw()

   screen.font_face(10)
   screen.font_size(15)
   screen.level(5)
   screen.move(WIDTH/2, HEIGHT/2-4)
   screen.text_center("lira-8")
   screen.stroke()

   screen.update()
end

-- Local Variables:
-- flycheck-luacheck-standards: ("lua51" "norns")
-- End:
