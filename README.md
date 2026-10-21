# rpi-cloud-init-generator

This project provides a collection of tools to provision Raspberry Pi nodes using `cloud-init`. Whether you need a fully automated image build, a simple static configuration, or an interactive generator, you can find a solution here.

Nodes can be set up with any combination of:

- **k3s** (first control plane, additional control plane, or worker)
- **ArgoCD HA** with GitHub App, SSH, HTTPS token, or public-repo access, bootstrapped with an ApplicationSet for GitOps
- **Twingate Connector**
- **Prometheus node_exporter**
- **BlinkStick** USB LED status indicators
- A **provisioning report** printed at the end of first boot

## Quick Start

```bash
cd 3-interactive-generator
./make-user-data-v3.sh
# output: 3-interactive-generator/output/<timestamp>_<role>-<hostname>/user-data
```

Flash Ubuntu Server with Raspberry Pi Imager, then copy the generated `user-data` onto the SD card's `system-boot` partition. See the [Interactive Generator README](./3-interactive-generator/README.md) for details.

> ⚠️ Generated `user-data` files contain plaintext secrets (k3s token, Twingate tokens, GitHub App/SSH private keys). `output/` is gitignored, so don't commit it, and treat the SD card as sensitive.

## Overview

There are three distinct methods available for generating a `user-data` configuration for your Raspberry Pi. Choose the one that best fits your needs and refer to the `README.md` inside the corresponding directory for detailed instructions.

### 1. Packer Automation (`1-packer-automation/`)

This directory contains the tools for fully automated image creation using Packer. This is the most advanced option, ideal for creating identical, pre-configured OS images for production or frequent deployments. **Status: planned, not yet implemented.**

**Use this when:** You want a completely "hands-off" process that produces a final `.img` file.

➡️ **[Go to Packer Automation README](./1-packer-automation/README.md)**

### 2. Static Configurations (`2-static-configs/`)

This directory contains a collection of pre-built, static `user-data` files. These are ready-to-use configurations for common setups.

**Use this when:** You need a quick, simple setup and are comfortable with minor manual edits to a pre-existing file.

➡️ **[Go to Static Configs README](./2-static-configs/README.md)**

### 3. Interactive Generator (`3-interactive-generator/`)

This directory contains an interactive shell script that asks you a series of questions to generate a custom `user-data` file tailored to your specific needs.

**Use this when:** You want to customize your node's setup without the complexity of a full Packer build.

➡️ **[Go to Interactive Generator README](./3-interactive-generator/README.md)**

## Development

A devcontainer (`.devcontainer/`) provides Ubuntu with `shellcheck` preinstalled. There's no CI yet. Known bugs and planned work are tracked in [TODO.md](./TODO.md).
