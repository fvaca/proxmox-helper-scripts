#!/usr/bin/env bash
# =======================================================================================
# Title:          pve-k3s-install.sh
# Description:    Installs k3s (Lightweight Kubernetes) on a Proxmox VM (Ubuntu/Debian)
# Author:         freddy vaca (GhatGPT 4o)
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

echo -e "${CYAN}=== k3s Installation Script for Proxmox VM ===${RESET}"

# =======================================================================================
# System Update & Dependencies
# =======================================================================================
echo -e "${GREEN}[Step 1/5] Updating system packages...${RESET}"
apt update && apt upgrade -y

echo -e "${GREEN}[Step 2/5] Disabling Swap (required for Kubernetes)...${RESET}"
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo -e "${GREEN}[Step 3/5] Installing required dependencies...${RESET}"
apt install -y curl

# =======================================================================================
# Install k3s
# =======================================================================================
echo -e "${GREEN}[Step 4/5] Installing k3s...${RESET}"
curl -sfL https://get.k3s.io | sh -

# =======================================================================================
# Configure kubectl
# =======================================================================================
echo -e "${GREEN}[Step 5/5] Configuring kubectl access...${RESET}"
mkdir -p $HOME/.kube
cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
chown $(whoami):$(whoami) $HOME/.kube/config
echo "export KUBECONFIG=$HOME/.kube/config" >> ~/.bashrc
source ~/.bashrc

# =======================================================================================
# Verify Installation
# =======================================================================================
echo -e "${CYAN}Verifying k3s installation...${RESET}"
sleep 5
kubectl get nodes

echo -e "${GREEN}✅ k3s installation completed successfully! 🚀${RESET}"
exit 0