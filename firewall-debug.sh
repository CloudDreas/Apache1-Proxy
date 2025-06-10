#!/bin/bash

# Function to reset firewall to default settings
reset_firewall() {
    echo "Resetting UFW to factory defaults..."
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default deny outgoing
    echo "Firewall reset complete!"
}

# Function to open specific port
open_port() {
    PS3="Select port to open: "
    options=(
        "SSH (22) - Inbound"
        "SMTP (25) - Inbound" 
        "HTTP (80) - Inbound"
        "HTTPS (443) - Inbound"
        "SMTP Submission (587) - Outbound"
        "Return to Main Menu"
    )
    
    select opt in "${options[@]}"; do
        case $REPLY in
            1) sudo ufw allow 22/tcp; break ;;
            2) sudo ufw allow 25/tcp; break ;;
            3) sudo ufw allow 80/tcp; break ;;
            4) sudo ufw allow 443/tcp; break ;;
            5) sudo ufw allow out 587/tcp; break ;;
            6) break ;;
            *) echo "Invalid option";;
        esac
    done
}

# Function to check firewall status
check_status() {
    clear
    echo "Current Firewall Status:"
    sudo ufw status numbered | grep -v 'Status: active'
    read -p "Press Enter to continue..."
}

# Function to check firewall logs
check_logs() {
    echo "Blocked Connection Logs:"
    sudo grep -E 'UFW BLOCK' /var/log/ufw.log || echo "No blocked connections found"
    read -p "Press Enter to continue..."
}

# Main menu
main_menu() {
    while true; do
        clear
        echo "=== UFW Management Menu ==="
        echo "1) Reset Firewall to Defaults"
        echo "2) Open Specific Port"
        echo "3) Check Firewall Status"
        echo "4) View Blocked Connections"
        echo "5) Exit"
        
        read -p "Select option [1-5]: " choice
        
        case $choice in
            1) reset_firewall ;;
            2) open_port ;;
            3) check_status ;;
            4) check_logs ;;
            5) echo "Exiting..."; break ;;
            *) echo "Invalid option";;
        esac
    done
}

# Start the menu
main_menu
