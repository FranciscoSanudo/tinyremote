#!/usr/bin/env bash
set -euo pipefail

# Simple entrypoint for the container: install packages (if needed), start Xvfb, VNC and i3
# This script aims to be idempotent and non-interactive.

install_packages() {
    # If you want to run package installation at container build time, prefer doing it in the Dockerfile.
    if [ -x "/usr/local/bin/install_packages.sh" ]; then
        /usr/local/bin/install_packages.sh || true
    fi
}

start_xvfb() {
    echo "Starting Xvfb on ${DISPLAY:-:1}..."
    Xvfb ${DISPLAY:-:1} -screen 0 ${SCREEN_RESOLUTION:-1920x1080}x${SCREEN_DEPTH:-24} &
    sleep 2
    # enable key autorepeat
    DISPLAY=${DISPLAY:-:1} xset r on || true
    DISPLAY=${DISPLAY:-:1} xset r rate 300 50 || true
}

start_vnc() {
    echo "Starting x11vnc on port ${VNC_PORT:-5901}..."
    # If VNC_PASSWORD is set, use it; otherwise run without password but bind to 127.0.0.1 by default.
    if [ -n "${VNC_PASSWORD:-}" ]; then
        mkdir -p /root/.vnc
        echo "${VNC_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd
        chmod 600 /root/.vnc/passwd
        x11vnc -display ${DISPLAY:-:1} -rfbport ${VNC_PORT:-5901} -forever -rfbauth /root/.vnc/passwd &
    else
        # bind to 127.0.0.1 by default to reduce exposure
        x11vnc -display ${DISPLAY:-:1} -rfbport ${VNC_PORT:-5901} -localhost -nopw -forever &
    fi
    sleep 2
}

start_i3() {
    echo "Starting i3 window manager..."
    # Run i3 in background; ensure XAUTHORITY and DISPLAY are set if needed
    i3 &
    sleep 2
}

check_health() {
    # Basic checks to ensure processes are running
    if ! pgrep -f Xvfb > /dev/null; then
        echo "Xvfb is not running!"
        return 1
    fi
    if ! pgrep -f x11vnc > /dev/null; then
        echo "x11vnc is not running!"
        return 1
    fi
    if ! pgrep -f i3 > /dev/null; then
        echo "i3 is not running!"
        return 1
    fi
    return 0
}

main() {
    install_packages
    start_xvfb
    start_vnc
    start_i3

    echo "Setup complete! VNC server is running on port ${VNC_PORT:-5901}"
    echo "Connect using VNC viewer at localhost:${VNC_PORT:-5901} (or bind address configured in docker-compose)"

    # Keep container running and check health every 30 seconds
    while true; do
        check_health || echo "Health check failed at $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        sleep ${HEALTH_INTERVAL:-30}
    done
}

main
