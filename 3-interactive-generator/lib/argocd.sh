#!/usr/bin/env bash

setup_argocd() {
    INSTALL_ARGOCD="N"
    if [[ "$INSTALL_K3S" =~ ^[Yy]$ ]] && [[ "$ROLE" == "first-control" ]]; then
        INSTALL_ARGOCD=$(ask "Install ArgoCD HA? (y/N)" "N")
        
        if [[ "$INSTALL_ARGOCD" =~ ^[Yy]$ ]]; then
            echo "Configure repository access for ArgoCD:"
            
            # Ask for repo URL
            ARGOCD_REPO_URL=$(ask "Repository URL (e.g., https://github.com/org/repo.git)")
            
            # Ask for authentication method
            echo "Select authentication method:"
            select ARGOCD_AUTH_METHOD in "github-app" "ssh" "https-token" "https-public"; do
                [[ -n "${ARGOCD_AUTH_METHOD:-}" ]] && break
            done
            
            case "$ARGOCD_AUTH_METHOD" in
                "github-app")
                    GITHUB_APP_ID=$(ask "GitHub App ID")
                    GITHUB_APP_INSTALLATION_ID=$(ask "GitHub App Installation ID")
                    echo "Enter GitHub App Private Key (paste key OR path to .pem file):"
                    read -r PRIVATE_KEY_INPUT
                    if [[ -f "$PRIVATE_KEY_INPUT" ]]; then
                        GITHUB_APP_PRIVATE_KEY=$(<"$PRIVATE_KEY_INPUT")
                    else
                        GITHUB_APP_PRIVATE_KEY="$PRIVATE_KEY_INPUT"
                    fi
                    export GITHUB_APP_ID GITHUB_APP_INSTALLATION_ID GITHUB_APP_PRIVATE_KEY
                    ;;
                "ssh")
                    echo "Enter SSH private key (paste key OR path to private key file):"
                    read -r SSH_KEY_INPUT
                    if [[ -f "$SSH_KEY_INPUT" ]]; then
                        SSH_PRIVATE_KEY=$(<"$SSH_KEY_INPUT")
                    else
                        SSH_PRIVATE_KEY="$SSH_KEY_INPUT"
                    fi
                    export SSH_PRIVATE_KEY
                    ;;
                "https-token")
                    GITHUB_USERNAME=$(ask "Git username")
                    GITHUB_TOKEN=$(ask_secret "Personal access token")
                    export GITHUB_USERNAME GITHUB_TOKEN
                    ;;
                "https-public")
                    echo "Note: This method is for public repositories only"
                    echo "For private repos, use 'github-app', 'ssh' or 'https-token' authentication."
                    echo "Press Enter to continue with public repo access..."
                    read -r
                    ;;
            esac
            
            # Export common variables
            export ARGOCD_REPO_URL ARGOCD_AUTH_METHOD
        fi
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
        
        # Add repository configuration based on auth method
        if [[ -n "${ARGOCD_REPO_URL:-}" ]]; then
            config+=$'\n'
            config+="  # Create ArgoCD Repository Secret"$'\n'
            config+="  - |"$'\n'
            config+="    kubectl apply -f - <<EOF"$'\n'
            config+="    apiVersion: v1"$'\n'
            config+="    kind: Secret"$'\n'
            config+="    metadata:"$'\n'
            config+="      name: argocd-repository-default"$'\n'
            config+="      namespace: argocd"$'\n'
            config+="      labels:"$'\n'
            config+="        argocd.argoproj.io/secret-type: repository"$'\n'
            config+="    stringData:"$'\n'
            config+="      url: $ARGOCD_REPO_URL"$'\n'
            config+="    EOF"$'\n'
            
            # Create credentials secret based on auth method
            case "$ARGOCD_AUTH_METHOD" in
                "github-app")
                    config+=$'\n'
                    config+="  # Create ArgoCD Repository Credentials Secret"$'\n'
                    config+="  - |"$'\n'
                    config+="    kubectl apply -f - <<EOF"$'\n'
                    config+="    apiVersion: v1"$'\n'
                    config+="    kind: Secret"$'\n'
                    config+="    metadata:"$'\n'
                    config+="      name: argocd-repository-default-creds"$'\n'
                    config+="      namespace: argocd"$'\n'
                    config+="      labels:"$'\n'
                    config+="        argocd.argoproj.io/secret-type: repo-creds"$'\n'
                    config+="    stringData:"$'\n'
                    config+="      url: $ARGOCD_REPO_URL"$'\n'
                    config+="      type: git"$'\n'
                    config+="      project: default"$'\n'
                    config+="      githubAppID: \"$GITHUB_APP_ID\""$'\n'
                    config+="      githubAppInstallationID: \"$GITHUB_APP_INSTALLATION_ID\""$'\n'
                    config+="      githubAppPrivateKey: |-"$'\n'
                    # Add the private key with proper indentation
                    local formatted_key
                    formatted_key=$(printf '%s\n' "$GITHUB_APP_PRIVATE_KEY" | sed 's/^/        /')
                    config+="$formatted_key"$'\n'
                    config+="    EOF"$'\n'
                    ;;
                "ssh")
                    config+=$'\n'
                    config+="  # Create ArgoCD Repository Credentials Secret (SSH)"$'\n'
                    config+="  - |"$'\n'
                    config+="    kubectl apply -f - <<EOF"$'\n'
                    config+="    apiVersion: v1"$'\n'
                    config+="    kind: Secret"$'\n'
                    config+="    metadata:"$'\n'
                    config+="      name: argocd-repository-default-creds"$'\n'
                    config+="      namespace: argocd"$'\n'
                    config+="      labels:"$'\n'
                    config+="        argocd.argoproj.io/secret-type: repo-creds"$'\n'
                    config+="    stringData:"$'\n'
                    config+="      url: $ARGOCD_REPO_URL"$'\n'
                    config+="      type: git"$'\n'
                    config+="      project: default"$'\n'
                    config+="      sshPrivateKey: |-"$'\n'
                    # Add the SSH key with proper indentation
                    local formatted_key
                    formatted_key=$(printf '%s\n' "$SSH_PRIVATE_KEY" | sed 's/^/        /')
                    config+="$formatted_key"$'\n'
                    config+="    EOF"$'\n'
                    ;;
                "https-public")
                    # No credentials secret needed for public repositories
                    ;;
                "https-token")
                    config+=$'\n'
                    config+="  # Create ArgoCD Repository Credentials Secret (HTTPS Token)"$'\n'
                    config+="  - |"$'\n'
                    config+="    kubectl apply -f - <<EOF"$'\n'
                    config+="    apiVersion: v1"$'\n'
                    config+="    kind: Secret"$'\n'
                    config+="    metadata:"$'\n'
                    config+="      name: argocd-repository-default-creds"$'\n'
                    config+="      namespace: argocd"$'\n'
                    config+="      labels:"$'\n'
                    config+="        argocd.argoproj.io/secret-type: repo-creds"$'\n'
                    config+="    stringData:"$'\n'
                    config+="      url: $ARGOCD_REPO_URL"$'\n'
                    config+="      type: git"$'\n'
                    config+="      project: default"$'\n'
                    config+="      username: \"$GITHUB_USERNAME\""$'\n'
                    config+="      password: \"$GITHUB_TOKEN\""$'\n'
                    config+="    EOF"$'\n'
                    ;;
            esac
            
            # Create ApplicationSet for Dynamic GitOps Environment Discovery
            if [[ "${ARGOCD_AUTH_METHOD}" != "https-public" ]] || [[ -n "${ARGOCD_REPO_URL:-}" ]]; then
                config+=$'\n'
                config+="  # Create ApplicationSet for Dynamic Environment Discovery"$'\n'
                config+="  - |"$'\n'
                config+="    kubectl apply -f - <<EOF"$'\n'
                config+="    apiVersion: argoproj.io/v1alpha1"$'\n'
                config+="    kind: ApplicationSet"$'\n'
                config+="    metadata:"$'\n'
                config+="      name: environments-appset"$'\n'
                config+="      namespace: argocd"$'\n'
                config+="    spec:"$'\n'
                config+="      generators:"$'\n'
                config+="      - git:"$'\n'
                config+="          repoURL: $ARGOCD_REPO_URL"$'\n'
                config+="          revision: HEAD"$'\n'
                config+="          directories:"$'\n'
                config+="          - path: environments/*/gitops"$'\n'
                config+="      template:"$'\n'
                config+="        metadata:"$'\n'
                config+="          name: '{{path[1]}}-env'"$'\n'
                config+="        spec:"$'\n'
                config+="          project: default"$'\n'
                config+="          source:"$'\n'
                config+="            repoURL: $ARGOCD_REPO_URL"$'\n'
                config+="            targetRevision: HEAD"$'\n'
                config+="            path: '{{path}}'"$'\n'
                config+="          destination:"$'\n'
                config+="            server: https://kubernetes.default.svc"$'\n'
                config+="            namespace: argocd"$'\n'
                config+="          syncPolicy:"$'\n'
                config+="            automated:"$'\n'
                config+="              prune: true"$'\n'
                config+="              selfHeal: true"$'\n'
                config+="            syncOptions:"$'\n'
                config+="              - CreateNamespace=true"$'\n'
                config+="    EOF"$'\n'
            fi

        fi
    fi
    echo "$config"
}

# Generate GitOps repository structure templates
generate_gitops_templates() {
    if [[ "$INSTALL_ARGOCD" =~ ^[Yy]$ ]] && [[ -n "${ARGOCD_REPO_URL:-}" ]]; then
        echo
        echo "=== GitOps Repository Structure Templates ==="
        echo
        echo "To complete your ArgoCD setup, create this structure in your repository:"
        echo "📁 Repository: $ARGOCD_REPO_URL"
        echo
        echo "environments/"
        echo "├── production/"
        echo "│   └── gitops/"
        echo "│       ├── applications.yaml"
        echo "│       └── apps/"
        echo "│           ├── nginx/"
        echo "│           └── homepage/"
        echo "└── staging/"
        echo "    └── gitops/"
        echo "        ├── applications.yaml"
        echo "        └── apps/"
        echo
        echo "🎯 Quick Start Commands:"
        echo "mkdir -p environments/production/gitops/apps"
        echo "mkdir -p environments/staging/gitops/apps"
        echo
        echo "📋 Copy the example templates from the documentation above"
        echo "   and customize for your environment needs."
        echo
        echo "✅ Once committed, ArgoCD will automatically discover and deploy"
        echo "   all applications in each environment's gitops folder!"
        echo
    fi
}