# HostsRedirectScreenTimeLimiter
A set of shell scripts for macOS that locks your `/etc/hosts` file so it cannot be edited, with a few simple terminal commands command to temporarily unblock a site for 2 minutes before automatically re-blocking it. I found this helpful for myself, and figure others might enjoy it as well, so I put it here.

I made this for Mac! Run at your own risk.

---

## How It Works

- Your `/etc/hosts` file is made **immutable** using macOS's `chflags schg` flag, meaning nothing (not even `sudo`) can edit or delete it without first removing that flag.
- When you want to temporarily access a blocked site, you run one command. The script lifts the lock, removes that site's entries, re-locks the file, waits 5 minutes, then restores and re-locks everything automatically in the background.
- The scripts themselves are also locked so you cannot accidentally (or impulsively) modify them.

---

## Files

| File | Purpose |
|---|---|
| `setup.sh` | Saves the current hosts file as the protected baseline and locks it |
| `unblock.sh` | Temporarily removes a site from the hosts file for 5 minutes |
| `unlock.sh` | Permanently unlocks the hosts file so you can make lasting edits |

---

## Initial Setup

### Step 1: Edit your hosts file first

Before locking anything, make sure your hosts file already contains all the sites you want blocked. Open Terminal and run:

```bash
sudo nano /etc/hosts
```

Add entries in this format, one per line:

```
127.0.0.1   youtube.com
127.0.0.1   www.youtube.com
```

Save and exit (`Ctrl + X`, then `Y`, then `Enter`).

### Step 2: Download the scripts

Clone this repo or download the three `.sh` files into a folder. A good location is a dedicated folder in your home directory:

```bash
mkdir ~/hosts-guardian
```

Move the files there if needed:

```bash
mv ~/Downloads/setup.sh ~/hosts-guardian/
mv ~/Downloads/unblock.sh ~/hosts-guardian/
mv ~/Downloads/unlock.sh ~/hosts-guardian/
```

### Step 3: Make the scripts executable

```bash
cd ~/hosts-guardian
chmod +x *.sh
```

### Step 4: Run setup

```bash
sudo bash setup.sh
```

This will save your current `/etc/hosts` as the protected baseline and lock the file immediately. No reboot is needed.

### Step 5: Lock the scripts themselves

To prevent the scripts from being edited or deleted:

```bash
sudo chflags schg setup.sh unblock.sh unlock.sh
```

---

## Daily Usage

To temporarily unblock a site for 5 minutes:

```bash
cd ~/hosts-guardian
sudo bash unblock.sh youtube.com
```

Or run it from anywhere using the full path:

```bash
sudo bash ~/hosts-guardian/unblock.sh youtube.com
```

The script will:
1. Remove all lines in `/etc/hosts` containing that domain name
2. Re-lock the hosts file immediately
3. Wait 5 minutes in the background
4. Restore the original blocked state and flush the DNS cache automatically

You can close the Terminal window after running the command. The restore will still happen in the background.

---

## Making Permanent Changes to the Block List

If you want to add or remove sites from the permanent block list, you need to temporarily unlock the hosts file, make your edits, and re-lock it.

```bash
cd ~/hosts-guardian

# Unlock the scripts first
sudo chflags noschg setup.sh unblock.sh unlock.sh

# Unlock the hosts file
sudo bash unlock.sh

# Edit the hosts file
sudo nano /etc/hosts

# Save the new state as the baseline and re-lock everything
sudo bash setup.sh

# Re-lock the scripts
sudo chflags schg setup.sh unblock.sh unlock.sh
```

---

## Some Other Notes

### DNS Caching

After a site is re-blocked, your browser (esp chrome) may still be able to reach it for a short time due to DNS caching. If this happens:

1.  Quit and reopen your browser entirely (`Cmd + Q`).
3. If that does not work, clear your browser's internal DNS cache.
   - Chrome: go to `chrome://net-internals/#dns` and click **Clear host cache**

The scripts automatically flush the macOS system DNS cache when re-blocking, but browsers like to maintain their own separate cache.

### How Strong Is the Lock?

The `chflags schg` flag is a strong deterrent. Even `sudo` cannot edit the file without first running `sudo chflags noschg /etc/hosts`. However, anyone who knows this command and has your sudo password can still bypass it.

If you need a truly unbreakable lock, the next level is enabling SIP (System Integrity Protection) restrictions, which would require booting into Recovery Mode to make any changes. That is beyond the scope of this project.

### The Scripts Themselves

After running `sudo chflags schg` on the scripts, they are also immutable. To modify them you would first need to run:

```bash
sudo chflags noschg ~/hosts-guardian/setup.sh
# (or whichever script you want to edit)
```

--

## Uninstalling

```bash
# Unlock the scripts
sudo chflags noschg ~/hosts-guardian/setup.sh ~/hosts-guardian/unblock.sh ~/hosts-guardian/unlock.sh

# Unlock the hosts file
sudo chflags noschg /etc/hosts
sudo chmod 644 /etc/hosts

# Remove the backup and scripts
sudo rm /etc/hosts.locked_backup
rm -rf ~/hosts-guardian
```
