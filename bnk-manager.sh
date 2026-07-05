#!/bin/bash

# Bnk Manager Script - Interactive management tool for Bnk
# Provides menu-driven interface to manage forwarding rules and service

set -e

CONFIG_FILE="/etc/bnk/config.yaml"
SYSTEMD_SERVICE="bnk.service"
SERVICE_FILE="/etc/systemd/system/$SYSTEMD_SERVICE"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires root privileges${NC}"
        echo "Please run: sudo bnk-manager"
        exit 1
    fi
}

# Check if config file exists
check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Config file not found: $CONFIG_FILE${NC}"
        exit 1
    fi
}

# Display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║     Bnk Manager - Management Tool      ║"
    echo "║   TCP/UDP Traffic Forwarding Service   ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Get service status
get_service_status() {
    if systemctl is-active --quiet $SYSTEMD_SERVICE 2>/dev/null; then
        echo -e "${GREEN}● Running${NC}"
    else
        echo -e "${RED}● Stopped${NC}"
    fi
}

# Display main menu
show_main_menu() {
    show_banner
    
    echo -e "${YELLOW}Service Status: $(get_service_status)${NC}"
    echo ""
    echo -e "${BLUE}Main Menu:${NC}"
    echo "1. View forwarding rules"
    echo "2. Add new forwarding rule"
    echo "3. Delete forwarding rule"
    echo "4. Edit config file"
    echo ""
    echo -e "${BLUE}Service Management:${NC}"
    echo "5. Start service"
    echo "6. Stop service"
    echo "7. Restart service"
    echo "8. View service status"
    echo "9. Enable auto-start"
    echo "10. Disable auto-start"
    echo ""
    echo -e "${BLUE}Other:${NC}"
    echo "11. View logs"
    echo "12. Test configuration"
    echo "0. Exit"
    echo ""
    read -p "Select an option: " choice
}

# View forwarding rules
view_rules() {
    show_banner
    echo -e "${BLUE}Current Forwarding Rules:${NC}"
    echo ""
    
    if grep -q "^forwards:" "$CONFIG_FILE"; then
        # Extract and display rules
        sed -n '/^forwards:/,/^[^ ]/p' "$CONFIG_FILE" | grep -A 3 "name:" | while read -r line; do
            if [[ $line == *"name:"* ]]; then
                name=$(echo "$line" | sed 's/.*name: "\(.*\)".*/\1/')
                protocol_line=$(grep -A 1 "name: \"$name\"" "$CONFIG_FILE" | tail -1)
                protocol=$(echo "$protocol_line" | sed 's/.*protocol: "\(.*\)".*/\1/')
                listen_line=$(grep -A 2 "name: \"$name\"" "$CONFIG_FILE" | tail -1)
                listen=$(echo "$listen_line" | sed 's/.*listen: "\(.*\)".*/\1/')
                target_line=$(grep -A 3 "name: \"$name\"" "$CONFIG_FILE" | tail -1)
                target=$(echo "$target_line" | sed 's/.*target: "\(.*\)".*/\1/')
                
                echo -e "${GREEN}Name:${NC} $name"
                echo -e "${GREEN}Protocol:${NC} $protocol"
                echo -e "${GREEN}Listen:${NC} $listen"
                echo -e "${GREEN}Target:${NC} $target"
                echo "---"
            fi
        done
    else
        echo -e "${YELLOW}No forwarding rules found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Add new forwarding rule
add_rule() {
    show_banner
    echo -e "${BLUE}Add New Forwarding Rule${NC}"
    echo ""
    
    read -p "Rule name (e.g., http_forward): " rule_name
    if [ -z "$rule_name" ]; then
        echo -e "${RED}Error: Rule name cannot be empty${NC}"
        sleep 2
        return
    fi
    
    echo "Protocol (tcp/udp):"
    read -p "  Enter protocol: " protocol
    if [[ ! "$protocol" =~ ^(tcp|udp)$ ]]; then
        echo -e "${RED}Error: Protocol must be tcp or udp${NC}"
        sleep 2
        return
    fi
    
    read -p "Listen address (e.g., 0.0.0.0:8080): " listen_addr
    if [ -z "$listen_addr" ]; then
        echo -e "${RED}Error: Listen address cannot be empty${NC}"
        sleep 2
        return
    fi
    
    read -p "Target address (e.g., 192.168.1.1:80): " target_addr
    if [ -z "$target_addr" ]; then
        echo -e "${RED}Error: Target address cannot be empty${NC}"
        sleep 2
        return
    fi
    
    # Backup original config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    
    # Add new rule to config
    cat >> "$CONFIG_FILE" <<EOF

  - name: "$rule_name"
    protocol: "$protocol"
    listen: "$listen_addr"
    target: "$target_addr"
EOF
    
    echo -e "${GREEN}✓ Rule added successfully${NC}"
    echo -e "${YELLOW}Restart service to apply changes: sudo systemctl restart bnk${NC}"
    sleep 2
}

# Delete forwarding rule
delete_rule() {
    show_banner
    echo -e "${BLUE}Delete Forwarding Rule${NC}"
    echo ""
    
    read -p "Enter rule name to delete: " rule_name
    if [ -z "$rule_name" ]; then
        echo -e "${RED}Error: Rule name cannot be empty${NC}"
        sleep 2
        return
    fi
    
    if ! grep -q "name: \"$rule_name\"" "$CONFIG_FILE"; then
        echo -e "${RED}Error: Rule '$rule_name' not found${NC}"
        sleep 2
        return
    fi
    
    read -p "Are you sure you want to delete '$rule_name'? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled${NC}"
        sleep 2
        return
    fi
    
    # Backup original config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    
    # Remove the rule (remove from "- name:" to the next "- name:" or EOF)
    sed -i "/^  - name: \"$rule_name\"/,/^  - name:/{ /^  - name: \"$rule_name\"/,/^$/d; }; /^  - name:$/i\\  - name: \"$rule_name\"\n    protocol: \"tcp\"\n    listen: \"0.0.0.0:8080\"\n    target: \"localhost:80\"" "$CONFIG_FILE"
    
    # Simpler approach - use awk to remove the block
    awk -v name="$rule_name" '
        BEGIN { skip = 0 }
        /^  - name: "'"$rule_name"'"/ { skip = 1; next }
        skip && /^  - name:/ { skip = 0 }
        !skip { print }
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    
    echo -e "${GREEN}✓ Rule deleted successfully${NC}"
    echo -e "${YELLOW}Restart service to apply changes: sudo systemctl restart bnk${NC}"
    sleep 2
}

# Edit config file
edit_config() {
    show_banner
    echo -e "${BLUE}Edit Configuration File${NC}"
    echo ""
    echo "Choose editor:"
    echo "1. nano"
    echo "2. vi/vim"
    echo "3. Back"
    echo ""
    
    read -p "Select editor: " editor_choice
    
    case $editor_choice in
        1)
            nano "$CONFIG_FILE"
            echo -e "${YELLOW}Restart service to apply changes: sudo systemctl restart bnk${NC}"
            sleep 2
            ;;
        2)
            vim "$CONFIG_FILE"
            echo -e "${YELLOW}Restart service to apply changes: sudo systemctl restart bnk${NC}"
            sleep 2
            ;;
        3)
            return
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Start service
start_service() {
    show_banner
    echo -e "${BLUE}Starting Bnk service...${NC}"
    echo ""
    
    if systemctl start $SYSTEMD_SERVICE; then
        echo -e "${GREEN}✓ Service started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start service${NC}"
    fi
    sleep 2
}

# Stop service
stop_service() {
    show_banner
    echo -e "${BLUE}Stopping Bnk service...${NC}"
    echo ""
    
    if systemctl stop $SYSTEMD_SERVICE; then
        echo -e "${GREEN}✓ Service stopped successfully${NC}"
    else
        echo -e "${RED}✗ Failed to stop service${NC}"
    fi
    sleep 2
}

# Restart service
restart_service() {
    show_banner
    echo -e "${BLUE}Restarting Bnk service...${NC}"
    echo ""
    
    if systemctl restart $SYSTEMD_SERVICE; then
        echo -e "${GREEN}✓ Service restarted successfully${NC}"
        sleep 1
        systemctl status $SYSTEMD_SERVICE --no-pager
    else
        echo -e "${RED}✗ Failed to restart service${NC}"
    fi
    sleep 2
}

# View service status
view_status() {
    show_banner
    echo -e "${BLUE}Service Status:${NC}"
    echo ""
    
    systemctl status $SYSTEMD_SERVICE --no-pager
    
    echo ""
    read -p "Press Enter to continue..."
}

# Enable auto-start
enable_autostart() {
    show_banner
    echo -e "${BLUE}Enable Auto-start...${NC}"
    echo ""
    
    if systemctl enable $SYSTEMD_SERVICE; then
        echo -e "${GREEN}✓ Auto-start enabled${NC}"
    else
        echo -e "${RED}✗ Failed to enable auto-start${NC}"
    fi
    sleep 2
}

# Disable auto-start
disable_autostart() {
    show_banner
    echo -e "${BLUE}Disable Auto-start...${NC}"
    echo ""
    
    if systemctl disable $SYSTEMD_SERVICE; then
        echo -e "${GREEN}✓ Auto-start disabled${NC}"
    else
        echo -e "${RED}✗ Failed to disable auto-start${NC}"
    fi
    sleep 2
}

# View logs
view_logs() {
    show_banner
    echo -e "${BLUE}Service Logs (last 50 lines):${NC}"
    echo ""
    
    sudo journalctl -u $SYSTEMD_SERVICE -n 50 --no-pager
    
    echo ""
    read -p "Press Enter to continue..."
}

# Test configuration
test_config() {
    show_banner
    echo -e "${BLUE}Testing Configuration...${NC}"
    echo ""
    
    if bnk -config "$CONFIG_FILE" 2>&1 | head -20; then
        echo -e "${GREEN}✓ Configuration test passed${NC}"
    else
        echo -e "${RED}✗ Configuration test failed${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
main() {
    check_root
    check_config
    
    while true; do
        show_main_menu
        
        case $choice in
            1)
                view_rules
                ;;
            2)
                add_rule
                ;;
            3)
                delete_rule
                ;;
            4)
                edit_config
                ;;
            5)
                start_service
                ;;
            6)
                stop_service
                ;;
            7)
                restart_service
                ;;
            8)
                view_status
                ;;
            9)
                enable_autostart
                ;;
            10)
                disable_autostart
                ;;
            11)
                view_logs
                ;;
            12)
                test_config
                ;;
            0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run main
main
