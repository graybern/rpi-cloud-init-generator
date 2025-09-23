# Static Cloud-Init Configurations

This directory contains pre-built, static `cloud-init` `user-data` files for provisioning Raspberry Pi nodes. These configurations are designed for quick, non-interactive setup.

## Purpose

This approach is for users who want a simple, copy-and-paste solution without needing to generate a configuration interactively. Each file in this directory represents a complete, ready-to-use node configuration.

## When to Use This

- You need to quickly provision a node with a standard, pre-defined setup.
- You prefer to make minor customizations by editing a file directly rather than using an interactive script.
- You have a working configuration that you want to reuse without changes.

## Usage

1.  **Choose a Configuration**: Select the `user-data` file that matches your needs.
2.  **Customize (Optional)**: Open the chosen `user-data` file in a text editor and make any necessary changes, such as updating the `hostname` or adding your personal SSH public keys.
3.  **Flash the Image**: Use the modified `user-data` file with the Raspberry Pi Imager.

### Flashing with Raspberry Pi Imager

1.  Choose your desired OS (e.g., Ubuntu Server 22.04.3 LTS 64-bit).
2.  Choose your SD Card.
3.  Click "Next" -> "Edit settings".
4.  Under the "User-config" tab, check "Use custom user-config file" and select the `user-data` file from this directory.
5.  Click "Save", then "Write" to flash the card.

When the Raspberry Pi boots with this SD card, `cloud-init` will automatically apply the settings defined in the `user-data` file.
