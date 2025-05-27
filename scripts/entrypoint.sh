#!/usr/bin/env sh

# scripts/entrypoint.sh
#!/bin/bash

install_package() {
    /usr/local/bin/install_packages.sh
}


# Function to start Xvfb
start_xvfb() {
    echo "Starting Xvfb..."
    Xvfb $DISPLAY -screen 0 ${SCREEN_RESOLUTION}x${SCREEN_DEPTH} &
    sleep 2
    DISPLAY=$DISPLAY xset r on
    DISPLAY=$DISPLAY xset r rate 300 50
}

# Function to start VNC server
start_vnc() {
    echo "Starting VNC server..."
    x11vnc -display $DISPLAY -rfbport $VNC_PORT -nopw -forever &
    sleep 2
}

# Function to start i3
start_i3() {
    echo "Starting i3 window manager..."
    i3 &
    sleep 2
}

# Function to check health
check_health() {
    if ! pgrep Xvfb > /dev/null; then
        echo "Xvfb is not running!"
        exit 1
    fi
    if ! pgrep x11vnc > /dev/null; then
        echo "VNC server is not running!"
        exit 1
    fi
    if ! pgrep i3 > /dev/null; then
        echo "i3 is not running!"
        exit 1
    fi
}

# Main function
main() {
    package_install
    start_xvfb
    start_vnc
    start_i3

    echo "Setup complete! VNC server is running on port $VNC_PORT"
    echo "Connect using VNC viewer at localhost:$VNC_PORT"

    # Keep container running and check health every 30 seconds
    while true; do
        check_health
        sleep 30
    done
}

# Run main function
main
