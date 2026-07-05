#!/bin/bash

# Bnk Installation Script for Linux
# This script downloads and installs the latest Bnk release

set -e

VERSION="latest"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/bnk"
SYSTEMD_DIR="/etc/systemd/system"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect system architecture
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
}

# Detect OS
detect_os() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    case $OS in
        linux)
            echo "linux"
            ;;
        darwin)
            echo "darwin"
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
}

# Get latest release version
get_latest_version() {
    echo "Fetching latest version..."
    LATEST=$(curl -s https://api.github.com/repos/zhuvps1-hub/Bnk/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    if [ -z "$LATEST" ]; then
        echo -e "${RED}Failed to fetch latest version${NC}"
        exit 1
    fi
    echo "$LATEST"
}

# Download binary
download_binary() {
    local version=$1
    local os=$2
    local arch=$3
    local filename="bnk-${os}-${arch}"
    local download_url="https://github.com/zhuvps1-hub/Bnk/releases/download/${version}/${filename}"
    local temp_file="/tmp/${filename}"

    echo -e "${YELLOW}Downloading ${filename}...${NC}"
    
    if ! curl -L -o "$temp_file" "$download_url"; then
        echo -e "${RED}Failed to download binary${NC}"
        exit 1
    fi

    chmod +x "$temp_file"
    echo "$temp_file"
}

# Install binary
install_binary() {
    local binary_path=$1
    
    echo -e "${YELLOW}Installing to $INSTALL_DIR...${NC}"
    
    if ! sudo cp "$binary_path" "$INSTALL_DIR/bnk"; then
        echo -e "${RED}Failed to install binary${NC}"
        exit 1
    fi
    
    sudo chmod +x "$INSTALL_DIR/bnk"
    echo -e "${GREEN}Binary installed successfully${NC}"
}

# Create config directory and example config
create_config() {
    echo -e "${YELLOW}Creating config directory...${NC}"
    
    if ! sudo mkdir -p "$CONFIG_DIR"; then
        echo -e "${RED}Failed to create config directory${NC}"
        exit 1
    fi

    # Create example config if not exists
    if [ ! -f "$CONFIG_DIR/config.yaml" ]; then
        sudo tee "$CONFIG_DIR/config.yaml" > /dev/null <<'EOF'
# Bnk Configuration Example
# Edit this file to add your forwarding rules

forwards:
  # TCP Forward Example: Forward local port 8080 to a remote server on port 80
  - name: "http_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "example.com:80"

  # UDP Forward Example: Forward DNS queries
  - name: "dns_forward"
    protocol: "udp"
    listen: "0.0.0.0:5353"
    target: "8.8.8.8:53"
EOF
        echo -e "${GREEN}Example config created at $CONFIG_DIR/config.yaml${NC}"
    else
        echo -e "${YELLOW}Config file already exists, skipping${NC}"
    fi
}

# Create systemd service (optional)
create_systemd_service() {
    read -p "Do you want to create a systemd service? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Creating systemd service...${NC}"
        
        sudo tee "$SYSTEMD_DIR/bnk.service" > /dev/null <<EOF
[Unit]
Description=Bnk Traffic Forwarding Tool
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$CONFIG_DIR
ExecStart=$INSTALL_DIR/bnk -config $CONFIG_DIR/config.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload
        echo -e "${GREEN}Systemd service created${NC}"
        
        read -p "Do you want to start the service now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo systemctl start bnk
            sudo systemctl enable bnk
            echo -e "${GREEN}Service started and enabled${NC}"
            sudo systemctl status bnk
        fi
    fi
}

# Main installation
main() {
    echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Bnk Installation Script for Linux  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
    echo

    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ] && ! command -v sudo &> /dev/null; then
        echo -e "${RED}This script requires sudo or root privileges${NC}"
        exit 1
    fi

    # Detect system
    OS=$(detect_os)
    ARCH=$(detect_arch)
    echo -e "${GREEN}Detected: $OS/$ARCH${NC}"
    echo

    # Get latest version
    VERSION=$(get_latest_version)
    echo -e "${GREEN}Latest version: $VERSION${NC}"
    echo

    # Download binary
    BINARY_PATH=$(download_binary "$VERSION" "$OS" "$ARCH")
    echo

    # Install binary
    install_binary "$BINARY_PATH"
    echo

    # Create config
    create_config
    echo

    # Create systemd service
    create_systemd_service
    echo

    # Verification
    echo -e "${YELLOW}Verifying installation...${NC}"
    if bnk -h > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Installation successful!${NC}"
        echo
        echo -e "${GREEN}Next steps:${NC}"
        echo "1. Edit your config file:"
        echo -e "   ${YELLOW}sudo nano $CONFIG_DIR/config.yaml${NC}"
        echo
        echo "2. Test the installation:"
        echo -e "   ${YELLOW}bnk -config $CONFIG_DIR/config.yaml${NC}"
        echo
        echo "3. Or if you created a systemd service, start it:"
        echo -e "   ${YELLOW}sudo systemctl start bnk${NC}"
        echo
        echo "For more information, visit: https://github.com/zhuvps1-hub/Bnk"
    else
        echo -e "${RED}Installation verification failed${NC}"
        exit 1
    fi

    # Cleanup
    rm -f "$BINARY_PATH"
}

# Run main
main
