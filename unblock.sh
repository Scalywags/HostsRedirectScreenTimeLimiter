#!/bin/bash
# unblock.sh
# Temporarily removes a website from /etc/hosts for 5 minutes, then restores it.
# Usage: sudo bash unblock.sh example.com

set -e

HOSTS_PATH="/etc/hosts"
BACKUP_PATH="/etc/hosts.locked_backup"
DURATION=120  # 2 minutes in seconds

# ---- Validation ----

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo bash unblock.sh <website>"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: sudo bash unblock.sh <website>"
    echo "Example: sudo bash unblock.sh reddit.com"
    exit 1
fi

SITE="$1"

# Check if the site is actually in the hosts file
if ! grep -q "$SITE" "$HOSTS_PATH"; then
    echo "'$SITE' was not found in $HOSTS_PATH. Nothing to unblock."
    exit 1
fi

echo "==> Unblocking '$SITE' for 5 minutes..."

# ---- Unlock, edit, re-lock ----

# Save the current (locked) state as the restore point
cp "$HOSTS_PATH" "$BACKUP_PATH"

# Lift the immutable flag
chflags noschg "$HOSTS_PATH"

# Remove all lines containing the site (handles multiple entries)
sed -i '' "/$SITE/d" "$HOSTS_PATH"

# Re-lock the file immediately
chflags schg "$HOSTS_PATH"

echo "    '$SITE' is now unblocked."
echo "    It will be re-blocked in 5 minutes."

# ---- Wait, then restore in the background ----

(
    sleep "$DURATION"

    # Lift the lock again to restore
    chflags noschg "$HOSTS_PATH"

    # Restore from backup
    cp "$BACKUP_PATH" "$HOSTS_PATH"

    # Re-lock
    chflags schg "$HOSTS_PATH"

    # Flush the DNS cache so the block takes effect immediately
    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null || true

    echo "==> '$SITE' has been re-blocked and the hosts file is locked."
) &

echo "    (Running restore in background, PID $!)"
echo "    You can close this terminal safely."
