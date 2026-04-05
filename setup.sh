#!/bin/bash
# setup.sh
# Saves the current hosts file as the protected baseline and locks it.
# Run this once after you have finished editing your hosts file.
# Usage: sudo bash setup.sh

set -e

HOSTS_PATH="/etc/hosts"
BACKUP_PATH="/etc/hosts.locked_backup"

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo bash setup.sh"
    exit 1
fi

echo "==> Setting up hosts file lock..."

# Save a backup before locking
cp "$HOSTS_PATH" "$BACKUP_PATH"
chmod 444 "$BACKUP_PATH"
echo "    Baseline saved to $BACKUP_PATH"

# Make the hosts file read-only and immutable
chmod 444 "$HOSTS_PATH"
chflags schg "$HOSTS_PATH"

echo "    /etc/hosts is now locked and immutable."
echo ""
echo "To unblock a site temporarily:"
echo "    sudo bash unblock.sh <website>"
echo ""
echo "To permanently unlock the hosts file for editing:"
echo "    sudo bash unlock.sh"
