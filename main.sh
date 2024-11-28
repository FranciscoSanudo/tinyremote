#!/bin/bash

# Pull the Alpine image and create a container
docker run -d --name alpine_vnc -p 5901:5901 alpine:latest sleep infinity

# Install necessary packages in the container
docker exec -it alpine_vnc sh -c "apk update && \
    apk add firefox xvfb x11vnc --no-cache"

# Start Xvfb on display :1 with a specified screen resolution
docker exec -d alpine_vnc Xvfb :1 -screen 0 1920x1080x16

# Start x11vnc on port 5901, with dynamic resizing
docker exec -d alpine_vnc x11vnc -display :1 -rfbport 5901 -nopw -forever

# Start Firefox in full-screen mode on display :1
docker exec -d alpine_vnc sh -c "DISPLAY=:1 firefox --kiosk &"

echo "VNC server is now running on port 5901. Connect to it using <host_ip>:5901."

