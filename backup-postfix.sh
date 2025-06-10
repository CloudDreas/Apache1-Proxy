#!/bin/bash

BACKUP_ROOT="/backup"
TODAY=$(date +%Y%m%d)
BACKUP_DIR="$BACKUP_ROOT/postfix-$TODAY"

# Function to check for root permissions
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Try: sudo $0"
        exit 1
    fi
}

backup_postfix() {
    if [ ! -d "$BACKUP_ROOT" ]; then
        echo "Backup root directory $BACKUP_ROOT does not exist."
        echo "Attempting to create $BACKUP_ROOT..."
        if ! mkdir -p "$BACKUP_ROOT"; then
            echo "ERROR: Cannot create $BACKUP_ROOT. Permission denied."
            return
        fi
    fi

    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup directory $BACKUP_DIR already exists."
        read -p "Overwrite? (y/n): " yn
        if [ "$yn" != "y" ]; then
            echo "Backup aborted."
            return
        fi
    fi

    mkdir -p "$BACKUP_DIR"

    if [ -d /etc/postfix ]; then
        cp -a /etc/postfix/* "$BACKUP_DIR/"
        echo "Copied /etc/postfix."
    else
        echo "ERROR: /etc/postfix does not exist."
    fi

    if [ -f /etc/mailname ]; then
        cp /etc/mailname "$BACKUP_DIR/"
        echo "Copied /etc/mailname."
    fi

    if [ -f /etc/postfix/sasl_passwd ]; then
        cp /etc/postfix/sasl_passwd* "$BACKUP_DIR/"
        echo "Copied /etc/postfix/sasl_passwd*."
    fi

    echo "Backup complete: $BACKUP_DIR"
}

restore_postfix() {
    echo "Available backups:"
    ls -1d $BACKUP_ROOT/postfix-* 2>/dev/null || { echo "No backups found in $BACKUP_ROOT."; return; }
    read -p "Enter backup folder name to restore (e.g., postfix-$TODAY): " folder
    RESTORE_PATH="$BACKUP_ROOT/$folder"
    if [ ! -d "$RESTORE_PATH" ]; then
        echo "Backup directory $RESTORE_PATH not found!"
        return
    fi

    if [ -d "$RESTORE_PATH" ]; then
        if [ -d /etc/postfix ]; then
            cp -a "$RESTORE_PATH"/* /etc/postfix/
            echo "Restored /etc/postfix."
        else
            echo "ERROR: /etc/postfix does not exist."
        fi

        if [ -f "$RESTORE_PATH/mailname" ]; then
            cp "$RESTORE_PATH/mailname" /etc/mailname
            echo "Restored /etc/mailname."
        fi

        if ls "$RESTORE_PATH"/sasl_passwd* 1> /dev/null 2>&1; then
            cp "$RESTORE_PATH"/sasl_passwd* /etc/postfix/
            echo "Restored /etc/postfix/sasl_passwd*."
        fi

        postfix check
        systemctl restart postfix
        echo "Restore complete from $RESTORE_PATH"
    fi
}

check_root

while true; do
    echo "1) Backup Postfix config"
    echo "2) Restore Postfix config"
    echo "3) Exit"
    read -p "Choose an option: " opt
    case $opt in
        1) backup_postfix ;;
        2) restore_postfix ;;
        3) exit ;;
        *) echo "Invalid option" ;;
    esac
done
