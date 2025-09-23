#!/usr/bin/env bash

setup_argocd() {
    INSTALL_ARGOCD="N"
    if [[ "$INSTALL_K3S" =~ ^[Yy]$ ]] && [[ "$ROLE" == "first-control" ]]; then
        INSTALL_ARGOCD=$(ask "Install ArgoCD HA? (y/N)" "N")
    fi
}

get_argocd_runcmd() {
    local config=""
    if [[ "$INSTALL_ARGOCD" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/runcmd/argocd.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}