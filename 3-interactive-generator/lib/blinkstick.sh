#!/usr/bin/env bash

setup_blinkstick() {
    INSTALL_BLINKSTICK=$(ask "Install BlinkStick LED support? (y/N)" "N")
}

get_blinkstick_write_files() {
    local config=""
    if [[ "$INSTALL_BLINKSTICK" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/write_files/blinkstick.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}

get_blinkstick_runcmd() {
    local config=""
    if [[ "$INSTALL_BLINKSTICK" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/runcmd/blinkstick.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}