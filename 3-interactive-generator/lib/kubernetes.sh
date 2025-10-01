#!/usr/bin/env bash

setup_kubernetes() {
    echo "Select k3s role:"
    select ROLE in "first-control" "additional-control" "worker"; do 
        [[ -n "${ROLE:-}" ]] && break
    done

    K3S_SERVER_URL=""
    K3S_TOKEN=""

    case "$ROLE" in
        "first-control")
            K3S_TOKEN=$(openssl rand -hex 32)
            K3S_CMD="curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server --cluster-init"
            ;;
        "additional-control")
            K3S_SERVER_URL=$(ask "K3s server URL (e.g., https://server:6443)")
            K3S_TOKEN=$(ask "K3s token")
            K3S_CMD="curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server --server $K3S_SERVER_URL"
            ;;
        "worker")
            K3S_SERVER_URL=$(ask "K3s server URL (e.g., https://server:6443)")
            K3S_TOKEN=$(ask "K3s token")
            K3S_CMD="curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - agent --server $K3S_SERVER_URL"
            ;;
    esac
}

get_kubernetes_runcmd() {
    local config=""
    if [[ "$INSTALL_K3S" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/runcmd/k3s.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                line="${line//__K3S_CMD__/$K3S_CMD}"
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}