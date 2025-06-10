#!/bin/bash

# UFW Management Functions (previous functions remain unchanged)
# ... [Keep all previous UFW functions from earlier script] ...

# Postfix Troubleshooting Functions
postfix_troubleshooting() {
    while true; do
        clear
        echo "=== Postfix Troubleshooting Menu ==="
        echo "1) Check Postfix Status"
        echo "2) Verify Office365 Relay Configuration"
        echo "3) Test TLS Connectivity to Office365"
        echo "4) View Mail Queue"
        echo "5) Flush Mail Queue"
        echo "6) View Mail Logs"
        echo "7) Return to Main Menu"

        read -p "Select option [1-7]: " choice

        case $choice in
            1) check_postfix_status ;;
            2) verify_office365_config ;;
            3) test_tls_connectivity ;;
            4) view_mail_queue ;;
            5) flush_mail_queue ;;
            6) view_mail_logs ;;
            7) break ;;
            *) echo "Invalid option";;
        esac
    done
}

check_postfix_status() {
    echo "Postfix Service Status:"
    sudo systemctl status postfix -l
    read -p "Press Enter to continue..."
}

verify_office365_config() {
    echo "Checking Office365 Relay Configuration:"
    sudo postconf -n | grep -E 'relayhost|smtp_sasl|smtp_tls'
    echo -e "\nSASL Password File:"
    sudo cat /etc/postfix/sasl_passwd 2>/dev/null || echo "No SASL password file found"
    read -p "Press Enter to continue..."
}

test_tls_connectivity() {
    echo "Testing TLS to Office365 (smtp.office365.com:587):"
    openssl s_client -connect smtp.office365.com:587 -starttls smtp -tlsextdebug
    read -p "Press Enter to continue..."
}

view_mail_queue() {
    echo "Current Mail Queue:"
    sudo mailq
    read -p "Press Enter to continue..."
}

flush_mail_queue() {
    echo "Flushing Mail Queue:"
    sudo postsuper -d ALL
    read -p "Press Enter to continue..."
}

view_mail_logs() {
    echo "Recent Mail Logs:"
    sudo tail -f /var/log/mail.log | grep postfix
    read -p "Press Enter to continue..."
}

# Updated Main Menu
main_menu() {
    while true; do
        clear
        echo "=== Combined Debugging Menu ==="
        echo "1) UFW Firewall Management"
        echo "2) Postfix Troubleshooting"
        echo "3) Exit"

        read -p "Select option [1-3]: " choice

        case $choice in
            1) firewall_menu ;;
            2) postfix_troubleshooting ;;
            3) echo "Exiting..."; break ;;
            *) echo "Invalid option";;
        esac
    done
}

# Start the menu
main_menu
