#!/usr/bin/env bash

setup_monitoring() {
    INSTALL_MONITORING="N"
    if [[ "$ROLE" == "first-control" ]]; then
        INSTALL_MONITORING=$(ask "Install node exporter for Prometheus monitoring? (y/N)" "N")
    fi
}

get_monitoring_runcmd() {
    local config=""
    if [[ "${INSTALL_MONITORING:-N}" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/runcmd/monitoring.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                [[ "$line" =~ ^runcmd: ]] && continue
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}