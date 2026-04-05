#!/bin/bash
# unlock.sh
# Permanently unlocks /etc/hosts for editing.
# Run this when you want to make lasting changes to the hosts file.
# After editing, run setup.sh again to re-lock it.
# Usage: sudo bash unlock.sh

set -e

HOSTS_PATH="/etc/hosts"

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo bash unlock.sh"
    exit 1
fi

chflags noschg "$HOSTS_PATH"
chmod 644 "$HOSTS_PATH"

echo "==> /etc/hosts is now unlocked and editable."
echo ""
echo "Make your changes, then run the following to re-lock:"
echo "    sudo bash setup.sh"
