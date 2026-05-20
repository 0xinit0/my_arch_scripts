#!/bin/bash
cat << "EOF"

 █    ██  ██▓███  ▓█████▄  ▄▄▄     ▄▄▄█████▓▓█████  ██▓ ███▄    █   ▄████ 
 ██  ▓██▒▓██░  ██▒▒██▀ ██▌▒████▄   ▓  ██▒ ▓▒▓█   ▀ ▓██▒ ██ ▀█   █  ██▒ ▀█▒
▓██  ▒██░▓██░ ██▓▒░██   █▌▒██  ▀█▄ ▒ ▓██░ ▒░▒███   ▒██▒▓██  ▀█ ██▒▒██░▄▄▄░
▓▓█  ░██░▒██▄█▓▒ ▒░▓█▄   ▌░██▄▄▄▄██░ ▓██▓ ░ ▒▓█  ▄ ░██░▓██▒  ▐▌██▒░▓█  ██▓
▒▒█████▓ ▒██▒ ░  ░░▒████▓  ▓█   ▓██▒ ▒██▒ ░ ░▒████▒░██░▒██░   ▓██░░▒▓███▀▒
░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░ ▒▒▓  ▒  ▒▒   ▓▒█░ ▒ ░░   ░░ ▒░ ░░▓  ░ ▒░   ▒ ▒  ░▒   ▒ 
░░▒░ ░ ░ ░▒ ░      ░ ▒  ▒   ▒   ▒▒ ░   ░     ░ ░  ░ ▒ ░░ ░░   ░ ▒░  ░   ░ 
 ░░░ ░ ░ ░░        ░ ░  ░   ░   ▒    ░         ░    ▒ ░   ░   ░ ░ ░ ░   ░ 
   ░                 ░          ░  ░           ░  ░ ░           ░       ░ 
                   ░                                                      
                                                                          
                                                                          
                                                                          
EOF


# --- Setup Colors & Formatting ---
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}Starting Arch Linux Safe-Update Sequence...${NC}\n"

# --- 1. News Check (Informant) ---
echo -e "${YELLOW}[Step 1/5] Checking Arch Linux News...${NC}"
if ! sudo informant check; then
    echo -e "${RED}CRITICAL: Unread Manual Intervention news found!${NC}"
    echo -e "Please run 'informant read' to review before updating."
    exit 1
fi
echo -e "${GREEN}No urgent news. Proceeding...${NC}\n"

# --- 2. Pre-flight Check (What's being updated?) ---
echo -e "${YELLOW}[Step 2/5] Pending Updates:${NC}"
PENDING_PACMAN=$(checkupdates)
PENDING_AUR=$(yay -Qu)

if [ -z "$PENDING_PACMAN" ] && [ -z "$PENDING_AUR" ]; then
    echo "System is already up to date."
else
    echo -e "${BOLD}Official Packages:${NC}\n$PENDING_PACMAN"
    echo -e "\n${BOLD}AUR Packages:${NC}\n$PENDING_AUR"
    echo "------------------------------------------------"
fi

# --- 3. System Update (Pacman) ---
echo -e "\n${YELLOW}[Step 3/5] Updating System Packages...${NC}"
if sudo pacman -Syu; then
    echo -e "${GREEN}Pacman update successful.${NC}"
else
    echo -e "${RED}Pacman update failed! Aborting to prevent partial upgrades.${NC}"
    exit 1
fi

# --- 4. AUR & Flatpak Updates ---
echo -e "\n${YELLOW}[Step 4/5] Updating AUR and Flatpaks...${NC}"

# Update AUR via yay (sync only)
if yay -Sua; then
    echo -e "${GREEN}AUR update successful.${NC}"
else
    echo -e "${RED}AUR update encountered an error.${NC}"
fi

# Update Flatpaks
if flatpak update -y; then
    echo -e "${GREEN}Flatpak update successful.${NC}"
else
    echo -e "${RED}Flatpak update encountered an error.${NC}"
fi

# --- 5. Post-Update Maintenance (.pacnew check) ---
echo -e "\n${YELLOW}[Step 5/5] Checking for .pacnew files...${NC}"

# Find any .pacnew files in /etc
PACNEWS=$(sudo find /etc -type f -name "*.pacnew" 2>/dev/null)

if [ -n "$PACNEWS" ]; then
    echo -e "${RED}ATTENTION: The following .pacnew files require attention:${NC}"
    echo "$PACNEWS"
    echo -e "\n${BOLD}To manage, view, or merge these files, run:${NC}"
    echo -e "${GREEN}sudo pacdiff${NC}"
else
    echo -e "${GREEN}No new .pacnew files found. Your config is clean!${NC}"
fi

echo -e "\n${BOLD}${GREEN}Update sequence complete!${NC}"
