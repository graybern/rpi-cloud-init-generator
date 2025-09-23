#!/usr/bin/env bash

get_reporting_write_files() {
    local config=""
    local template="$SCRIPT_DIR/templates/write_files/provision-report.yaml"
    if [[ -f "$template" ]]; then
        while IFS= read -r line; do
            config+="  $line"$'\n'
        done < "$template"
    fi
    echo "$config"
}

get_reporting_runcmd() {
    local config=""
    local template="$SCRIPT_DIR/templates/runcmd/provision-report.yaml"
    if [[ -f "$template" ]]; then
        while IFS= read -r line; do
            config+="  $line"$'\n'
        done < "$template"
    fi
    echo "$config"
}