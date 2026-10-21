# CLAUDE.md

Guidance for Claude Code when working in this repo.

## What this is

Tools for generating cloud-init `user-data` files that provision Raspberry Pi nodes running Ubuntu Server. The files can set up k3s, ArgoCD, a Twingate Connector, Prometheus node_exporter and BlinkStick LEDs. The `user-data` file goes onto the SD card's `system-boot` partition after it's flashed with Raspberry Pi Imager.

- `1-packer-automation/`: placeholder; only a README so far.
- `2-static-configs/`: hand-maintained `user-data` examples. Secrets are `<PLACEHOLDER>` or dummy values.
- `3-interactive-generator/`: the main tool. A bash script that prompts for options and assembles `user-data` from templates.

## Generator architecture (`3-interactive-generator/`)

- `make-user-data-v3.sh`: the entry point. It sources `lib/*.sh`, prompts the user, then calls `generate_cloud_init`.
- `lib/<component>.sh`: `setup_<component>` handles the prompts and sets `INSTALL_<COMPONENT>`. `get_<component>_runcmd` and `get_<component>_write_files` read the templates, indent them by two spaces and substitute `__PLACEHOLDER__` tokens.
- `lib/cloud-init-generator.sh`: does the assembly. It fills `templates/cloud-init-base.yaml`, then appends `write_files:` and `runcmd:` in this fixed order: blinkstick → k3s → argocd → twingate → monitoring → provision-report.
- The provision report is always included. `/etc/provision-selections.env` records the chosen components, and `/usr/local/sbin/provision-report.sh` checks them at the end of first boot.
- ArgoCD is offered only when the k3s role is `first-control`. Repo auth can be `github-app`, `ssh` or `https-public`. It creates an ApplicationSet that finds `environments/*/gitops` in the repo.

To add a component, follow the "How It Works & Extending" section of `3-interactive-generator/README.md`.

## Conventions

- Bash with `set -euo pipefail`. Keep to the existing `ask` / `ask_secret` helpers in `lib/helpers.sh`.
- Template lines are indented by the `get_*` functions, so write templates at column 0.
- Each `runcmd` list item runs in its own shell. Variables don't carry over between items (see TODO.md).
- Lint with `shellcheck` (installed in the devcontainer). The generator runs `yamllint -d relaxed` on its output when `yamllint` is available.

## Secrets

Generated `user-data` holds plaintext secrets: the k3s token, Twingate tokens, the GitHub App private key or SSH deploy key, and the password hash. `3-interactive-generator/output/` is gitignored and must stay that way. Never commit generated output, and never put real values into `2-static-configs/`.

## CI

There are no GitHub Actions workflows, so pushing doesn't trigger anything.

## Open work

See `TODO.md`. It lists known bugs, including swapped Twingate tokens and a broken node_exporter install.
