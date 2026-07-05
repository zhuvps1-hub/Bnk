#!/bin/bash

# Bnk Uninstallation Script for Linux

set -e

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/bnk"
SYSTEMD_DIR="/etc/systemd/system"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Main uninstallation
main() {
    echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Bnk Uninstallation Script        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
    echo

    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ] && ! command -v sudo &> /dev/null; then
        echo -e "${RED}This script requires sudo or root privileges${NC}"
        exit 1
    fi

    # Stop systemd service if running
    if [ -f "$SYSTEMD_DIR/bnk.service" ]; then
        echo -e "${YELLOW}Stopping bnk service...${NC}"
        sudo systemctl stop bnk 2>/dev/null || true
        sudo systemctl disable bnk 2>/dev/null || true
        sudo rm -f "$SYSTEMD_DIR/bnk.service"
        sudo systemctl daemon-reload
        echo -e "${GREEN}Service stopped and removed${NC}"
    fi

    # Remove binary
    if [ -f "$INSTALL_DIR/bnk" ]; then
        echo -e "${YELLOW}Removing binary...${NC}"
        sudo rm -f "$INSTALL_DIR/bnk"
        echo -e "${GREEN}Binary removed${NC}"
    fi

    # Ask about config directory
    if [ -d "$CONFIG_DIR" ]; then
        read -p "Remove configuration directory $CONFIG_DIR? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf "$CONFIG_DIR"
            echo -e "${GREEN}Configuration directory removed${NC}"
        else
            echo -e "${YELLOW}Configuration directory preserved at $CONFIG_DIR${NC}"
        fi
    fi

    echo
    echo -e "${GREEN}✓ Uninstallation complete!${NC}"
}

# Run main
main
