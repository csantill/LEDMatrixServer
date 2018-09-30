#!/bin/sh
cd /home/pi/LEDMatrixServer/
sudo stdbuf -o0 python -u rpi-server.py &> /tmp/ledserver.log


