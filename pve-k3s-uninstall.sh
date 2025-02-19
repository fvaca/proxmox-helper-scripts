#!/usr/bin/env bash
# =======================================================================================
# Title:          pve-k3s-uninstall.sh
# Description:    Uninstalls k3s (Lightweight Kubernetes) from a Proxmox VM (Ubuntu/Debian)
# Author:         Your Name
# Version:        1.0
# License:        MIT
# =======================================================================================

set -e  # Exit on error
set -o pipefail  # Exit on command failures within pipes

# Colors for output
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root.${RESET}"
    exit 1
fi

echo -e "${CYAN}=== k3s Uninstallation Script for Proxmox VM ===${RESET}"

# =======================================================================================
# Stop k3s Service
# =======================================================================================
echo -e "${GREEN}[Step 1/4] Stopping k3s service...${RESET}"
systemctl stop k3s || true
systemctl disable k3s || true

# =======================================================================================
# Remove k3s Binaries & Configurations
# =======================================================================================
echo -e "${GREEN}[Step 2/4] Removing k3s binaries...${RESET}"
rm -rf /usr/local/bin/k3s
rm -rf /usr/local/bin/kubectl
rm -rf /usr/local/bin/crictl
rm -rf /usr/local/bin/ctr

echo -e "${GREEN}[Step 3/4] Removing k3s data & configurations...${RESET}"
rm -rf /etc/rancher/k3s
rm -rf /var/lib/rancher/k3s
rm -rf /var/lib/kubelet
rm -rf /etc/systemd/system/k3s.service
rm -rf /etc/systemd/system/k3s*

# =======================================================================================
# Remove k3s Networking & Firewall Rules
# =======================================================================================
echo -e "${GREEN}[Step 4/4] Cleaning up networking rules...${RESET}"
ip link delete cni0 || true
ip link delete flannel.1 || true
iptables --flush || true
iptables -tnat --flush || true

# =======================================================================================
# Final Cleanup & Reboot Prompt
# =======================================================================================
echo -e "${CYAN}k3s has been completely removed.${RESET}"
echo -e "${CYAN}A system reboot is recommended.${RESET}"

read -p "Would you like to reboot now? (y/n): " reboot_choice
if [[ $reboot_choice == "y" || $reboot_choice == "Y" ]]; then
    echo -e "${GREEN}Rebooting system...${RESET}"
    reboot
else
    echo -e "${GREEN}Uninstallation complete. Reboot later to finalize changes.${RESET}"
fi

exit 0