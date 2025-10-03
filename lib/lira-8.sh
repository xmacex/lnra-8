#!/bin/sh
cd /home/we/dust/code/lira-8/lib
# pd -jack -nojackconnect -nogui -realtime LIRA-8/LIRA-8_Pd_Standalone/_LIRA-8.pd & # Why does the upstream not work directyl, did I add something to it eg. a loadbang?
pd -jack -nojackconnect -nogui -realtime LIRA-8_Pd_Standalone/_LIRA-8.pd &
sleep 2
jack_connect pure_data:output_1 crone:input_1
jack_connect pure_data:output_2 crone:input_2
