# Dockerfile
FROM alpine:latest

# Set environment variables
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    SCREEN_RESOLUTION=1920x1080 \
    SCREEN_DEPTH=24 \
    HOME=/root \
    TERM=xterm

# Copy scripts and configs
COPY scripts/install_packages.sh /usr/local/bin/
COPY scripts/entrypoint.sh /usr/local/bin/
COPY config/i3config /root/.config/i3/config

# Make scripts executable
RUN chmod +x /usr/local/bin/install_packages.sh /usr/local/bin/entrypoint.sh

# Install base packages and clean up
RUN /usr/local/bin/install_packages.sh

# Expose VNC port
EXPOSE $VNC_PORT

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

