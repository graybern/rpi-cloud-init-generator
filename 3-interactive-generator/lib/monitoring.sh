#!/usr/bin/env bash

setup_monitoring() {
    INSTALL_MONITORING="N"
    INSTALL_MONITORING=$(ask "Install node exporter for Prometheus monitoring? (y/N)" "N")
}

get_monitoring_write_files() {
    local config=""
    if [[ "${INSTALL_MONITORING:-N}" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/write_files/monitoring.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                [[ "$line" =~ ^write_files: ]] && continue
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
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