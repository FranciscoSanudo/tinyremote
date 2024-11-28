#!/usr/bin/env sh

# scripts/install_packages.sh
#!/bin/sh

# Function to install base packages
install_base_packages() {
    apk update
    apk add --no-cache \
        i3wm \
        i3status \
        xvfb \
        x11vnc \
        terminus-font \
        dmenu \
        firefox \
        xterm \
        openssl \
        sudo \
        bash \
        curl \
        git \
        emacs \
        emacs-x11
}

# Function to create necessary directories
create_directories() {
    mkdir -p /root/.config/i3
    mkdir -p /root/.vnc
}

# Function to cleanup
cleanup() {
    rm -rf /var/cache/apk/*
}

# Main installation process
main() {
    echo "Installing base packages..."
    install_base_packages

    echo "Creating necessary directories..."
    create_directories

    echo "Creating doom emacs"
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install -y

    echo "Cleaning up..."
    cleanup

    echo "Installation complete!"
}

# Run main function
main
