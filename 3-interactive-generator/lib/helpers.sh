#!/usr/bin/env bash

# Quote string for YAML
yaml_q() { 
    sed 's/\\/\\\\/g; s/"/\\"/g' <<<"$1"
}

# Hash password using openssl
hash_pw() { 
    openssl passwd -6 "$1"
}

# Ask for input with optional default
ask() { 
    local p="$1" def="${2:-}"
    local a
    if [[ -n "$def" ]]; then
        read -r -p "$p [$def]: " a
    else
        read -r -p "$p: " a
    fi
    echo "${a:-$def}"
}

# Ask for secret input (hidden)
ask_secret() { 
    local p="$1" a
    read -r -s -p "$p: " a
    echo >&2 # Move to new line after silent input
    echo "$a"
}

# Convert string to slug
slug() { 
    tr '[:upper:]' '[:lower:]' <<<"$1" | \
    tr -cs 'a-z0-9-_' '-' | \
    sed 's/^-*//; s/-*$//'
}

# Create output directory
setup_output_dir() {
    OUT_BASE="${OUT_BASE:-./output}"
    STAMP="$(TZ=UTC date +'%Y-%m-%dT%H-%M-%SZ')"
    ROLE_SLUG="$(slug "$ROLE")"
    HOST_SLUG="$(slug "$HOSTNAME")"
    OUT_DIR="$OUT_BASE/${STAMP}_${ROLE_SLUG}-${HOST_SLUG}"
    mkdir -p "$OUT_DIR"
}

# Format SSH keys for YAML
format_ssh_keys() {
    local formatted="    ssh_authorized_keys:"
    for key in "$@"; do
        [[ -z "$key" ]] && continue
        formatted+=$'\n'"      - $key"
    done
    echo "$formatted"
}