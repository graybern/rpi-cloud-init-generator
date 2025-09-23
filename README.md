# rpi-cloud-init-generator

This project provides a collection of tools to provision Raspberry Pi nodes using `cloud-init`. Whether you need a fully automated image build, a simple static configuration, or an interactive generator, you can find a solution here.

## Overview

There are three distinct methods available for generating a `user-data` configuration for your Raspberry Pi. Choose the one that best fits your needs and refer to the `README.md` inside the corresponding directory for detailed instructions.

### 1. Packer Automation (`1-packer-automation/`)

This directory contains the tools for fully automated image creation using Packer. This is the most advanced option, ideal for creating identical, pre-configured OS images for production or frequent deployments.

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
