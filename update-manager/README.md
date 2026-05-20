# Safe Arch Linux Update Automation

A robust and user-friendly Bash script for safely updating an Arch Linux system, including official repositories, AUR packages, and Flatpaks — with built-in safeguards against partial upgrades and missed manual interventions.

---

## Features

- ✅ Checks official Arch Linux news before updating
- ✅ Prevents updates if manual intervention is required
- ✅ Displays pending official and AUR package updates
- ✅ Safely updates system packages with `pacman`
- ✅ Updates AUR packages using `yay`
- ✅ Updates Flatpak applications
- ✅ Detects `.pacnew` files after updates
- ✅ Colorized terminal output for readability
- ✅ Clean step-by-step workflow

---

## Workflow

The script performs the following sequence:

### 1. Arch News Verification

Uses `informant` to check for unread Arch Linux news items that may require manual intervention before updating.

If important news exists:
- The update process stops immediately
- Prevents dangerous or broken upgrades

---

### 2. Pre-Flight Update Check

Displays:
- Official repository package updates via `checkupdates`
- AUR package updates via `yay -Qu`

This gives you visibility into what will change before any packages are installed.

---

### 3. System Package Upgrade

Runs:

```bash
sudo pacman -Syu
```

If the update fails:
- The script aborts immediately
- Helps prevent partial upgrades

---

## Installation

```bash
git clone https://github.com/yourname/updatein.git
cd updatein
chmod +x updatein.sh
./updatein.sh
```
