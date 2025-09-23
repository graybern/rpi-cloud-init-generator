#!/usr/bin/env bash

setup_twingate() {
    INSTALL_TWINGATE=$(ask "Install Twingate? (y/N)" "N")
    if [[ "$INSTALL_TWINGATE" =~ ^[Yy]$ ]]; then
        TW_NET=$(ask "Twingate network")
        TW_AT=$(ask_secret "Twingate access token")
        TW_RT=$(ask_secret "Twingate refresh token")
    fi
}

get_twingate_runcmd() {
    local config=""
    if [[ "$INSTALL_TWINGATE" =~ ^[Yy]$ ]]; then
        local template="$SCRIPT_DIR/templates/runcmd/twingate.yaml"
        if [[ -f "$template" ]]; then
            while IFS= read -r line; do
                line="${line//__TW_NET__/$TW_NET}"
                line="${line//__TW_AT__/$TW_AT}"
                line="${line//__TW_RT__/$TW_RT}"
                config+="  $line"$'\n'
            done < "$template"
        fi
    fi
    echo "$config"
}