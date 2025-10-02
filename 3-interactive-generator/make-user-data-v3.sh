#!/usr/bin/env bash
set -euo pipefail
trap 'echo "ERROR on line $LINENO" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Initialize variables with defaults
export INSTALL_K3S="N"
export INSTALL_ARGOCD="N"
export INSTALL_TWINGATE="N"
export INSTALL_MONITORING="N"
export INSTALL_BLINKSTICK="N"
export OUT_DIR="$SCRIPT_DIR/output"
export ROLE="standalone"
export K3S_CMD=""

# Initialize password-related variables
export PW_HASH=""
export LOCK_PASSWD=true
export SSH_PWAUTH=false

# Source helper scripts
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/blinkstick.sh"
source "$SCRIPT_DIR/lib/kubernetes.sh"
source "$SCRIPT_DIR/lib/argocd.sh"
source "$SCRIPT_DIR/lib/twingate.sh"
source "$SCRIPT_DIR/lib/monitoring.sh"
source "$SCRIPT_DIR/lib/provision-report.sh"
source "$SCRIPT_DIR/lib/cloud-init-generator.sh"

# ---------- inputs ----------
HOSTNAME=$(ask "Hostname" "octolet-node")

# SSH key configuration
echo "Enter SSH public keys (paste key OR path to .pub). Blank line to finish."
SSH_KEYS=()
while :; do
    read -r -p "SSH key or path (empty to finish): " K
    [[ -z "$K" ]] && break
    [[ -f "$K" ]] && SSH_KEYS+=("$(<"$K")") || SSH_KEYS+=("$K")
done

# Password configuration
ENABLE_PW=$(ask $'\n'"Enable local password login? (y/N)" "N"$'\n'"(Not recommended; SSH keys are more secure.)")
if [[ "$ENABLE_PW" =~ ^[Yy]$ ]]; then
    while :; do
        PW1=$(ask_secret $'\n'"Enter password"); PW2=$(ask_secret $'\n'"Confirm password")
        [[ -n "$PW1" && "$PW1" == "$PW2" ]] && break || echo "Passwords don't match, try again."
    done
    PW_HASH=$(hash_pw "$PW1")
    LOCK_PASSWD=false
    SSH_PWAUTH=true
fi

# Kubernetes setup
INSTALL_K3S=$(ask $'\n'"Install Kubernetes (k3s)? (y/N)" "N")
if [[ "$INSTALL_K3S" =~ ^[Yy]$ ]]; then
    INSTALL_K3S="Y"; export INSTALL_K3S
    setup_kubernetes
    setup_argocd
else
    INSTALL_K3S="N"; export INSTALL_K3S
    INSTALL_ARGOCD="N"; export INSTALL_ARGOCD
fi

# Optional components
setup_blinkstick
if [[ "$INSTALL_BLINKSTICK" =~ ^[Yy]$ ]]; then
    INSTALL_BLINKSTICK="Y"; export INSTALL_BLINKSTICK
else
    INSTALL_BLINKSTICK="N"; export INSTALL_BLINKSTICK
fi

setup_monitoring
if [[ "$INSTALL_MONITORING" =~ ^[Yy]$ ]]; then
    INSTALL_MONITORING="Y"; export INSTALL_MONITORING
else
    INSTALL_MONITORING="N"; export INSTALL_MONITORING
fi

setup_twingate
if [[ "$INSTALL_TWINGATE" =~ ^[Yy]$ ]]; then
    INSTALL_TWINGATE="Y"; export INSTALL_TWINGATE
else
    INSTALL_TWINGATE="N"; export INSTALL_TWINGATE
fi

# Generate cloud-init configuration
generate_cloud_init

echo "Configuration complete! Output saved to: $OUT_DIR"