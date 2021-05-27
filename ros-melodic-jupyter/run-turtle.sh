#!/bin/bash
source devel/setup.bash
envsubst < /home/.lib/env.template.js > /home/.lib/env.js
sudo cp -rf /home/.lib/env.js /usr/share/nginx/html/env.js

roscore & 
roslaunch --wait io_turtle_sim_env simulation.launch &
roslaunch --wait io_turtle_command_center command_center.launch websocket_external_port:=`echo ${WS_ENV_PORT}` &
roslaunch --wait io_turtle turtle.launch &
