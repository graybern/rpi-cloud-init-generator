#!/usr/bin/env bash

generate_cloud_init() {
    setup_output_dir

    # Load base template
    local base_template="$SCRIPT_DIR/templates/cloud-init-base.yaml"
    if [[ ! -f "$base_template" ]]; then
        echo "Error: Base template not found at $base_template" >&2
        exit 1
    fi
    
    # --- Initialize Content Variables ---
    local config=""
    local write_files=""
    local runcmd=""


    # --- Build write_files Content ---
    if [[ "${INSTALL_BLINKSTICK:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        write_files+=$(get_blinkstick_write_files)$'\n'
    fi
    
    if [[ "${INSTALL_MONITORING:-N}" =~ ^[Yy]$ ]]; then
        write_files+=$(get_monitoring_write_files)$'\n'
    fi
    
    # Always include reporting write_files
    write_files+=$'\n' # Add a newline to separate file entries
    write_files+=$(get_reporting_write_files)$'\n'



    # --- Build runcmd Content ---
    runcmd+="  #========================================="$'\n'
    runcmd+="  # Base configuration"$'\n'
    runcmd+="  #========================================="$'\n'
    runcmd+="  - [ bash, -lc, \"set -euxo pipefail\" ]"$'\n'
    runcmd+="  - [ bash, -c, \"echo 'Starting setup...' > /root/setup-started\" ]"$'\n'

    # Add components in order with clear section separators
    if [[ "${INSTALL_BLINKSTICK:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+="  # Blinkstick configuration"$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+=$(get_blinkstick_runcmd)$'\n'
    fi

    if [[ "${INSTALL_K3S:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+="  # K3s configuration"$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+=$(get_kubernetes_runcmd)$'\n'
    fi

    if [[ "${INSTALL_ARGOCD:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+="  # ArgoCD configuration"$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+=$(get_argocd_runcmd)$'\n'
    fi

    if [[ "${INSTALL_TWINGATE:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+="  # Twingate configuration"$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+=$(get_twingate_runcmd)$'\n'
    fi

    if [[ "${INSTALL_MONITORING:-N}" =~ ^[Yy]$ ]]; then
        runcmd+=$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+="  # Monitoring configuration"$'\n'
        runcmd+="  #========================================="$'\n'
        runcmd+=$(get_monitoring_runcmd)$'\n'
    fi

    # Always add reporting at the end
    runcmd+=$'\n'
    runcmd+="  #========================================="$'\n'
    runcmd+="  # Reporting setup status"$'\n'
    runcmd+="  #========================================="$'\n'
    runcmd+=$(get_reporting_runcmd)$'\n'

    # Add completion marker
    runcmd+=$'\n'
    runcmd+="  #========================================="$'\n'
    runcmd+="  # Finalization"$'\n'
    runcmd+="  #========================================="$'\n'
    runcmd+="  - [ bash, -c, \"echo 'Setup complete.' > /root/setup-complete\" ]"$'\n'


    # --- Process Base Template ---
    local line
    while IFS= read -r line; do
        # Skip placeholders for sections that will be appended later
        if [[ "$line" =~ ^(write_files|runcmd): ]]; then
            continue
        fi

        if [[ "$line" =~ "__SSH_KEYS__" ]]; then
            if (( ${#SSH_KEYS[@]} > 0 )); then
                config+=$(format_ssh_keys "${SSH_KEYS[@]}")$'\n'
            fi
            continue
        fi

        line="${line//__HOSTNAME__/$(yaml_q "$HOSTNAME")}"
        line="${line//__SSH_PWAUTH__/$SSH_PWAUTH}"
        line="${line//__LOCK_PASSWD__/$LOCK_PASSWD}"
        
        if [[ "$line" =~ "__PASSWORD_HASH__" ]]; then
            [[ -n "$PW_HASH" ]] && config+="    passwd: \"$PW_HASH\""$'\n'
            continue
        fi
        
        config+="$line"$'\n'
    done < "$base_template"


    # --- Append Final Sections ---
    if [[ -n "$write_files" ]]; then
        config+=$'\nwrite_files:\n'"$write_files"
    fi

    if [[ -n "$runcmd" ]]; then
        config+=$'\nruncmd:\n'"$runcmd"
    fi

    # --- Add Final Message ---
    config+=$'\n'
    config+='# This is static; dynamic status is printed by the report script above.'$'\n'
    config+='final_message: "cloud-init complete. See console output / MOTD for provisioning status."'

    # --- Write Final Configuration ---
    echo -n "$config" > "$OUT_DIR/user-data"
    echo "Cloud-init configuration generated at: $OUT_DIR/user-data"

    # Validate YAML format (if available)
    if command -v yamllint >/dev/null 2>&1; then
        yamllint -d relaxed "$OUT_DIR/user-data" || echo "Warning: YAML validation failed"
    fi
}