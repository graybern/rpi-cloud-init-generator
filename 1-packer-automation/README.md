# Packer Automation for Raspberry Pi Images

This directory is intended for the fully automated creation of Raspberry Pi OS images using [HashiCorp Packer](https://www.packer.io/).

## Goal

The goal is to create a repeatable, "hands-off" process for building custom OS images. Instead of manually configuring an SD card with a `user-data` file, Packer will build a complete `.img` file with all software, configurations, and settings pre-installed.

This is the most advanced and robust of the three provisioning options, ideal for production environments or when you need to generate identical images frequently.

## Status: To Be Determined (TBD)

This part of the project is currently under development. The necessary Packer templates and build scripts will be added here in the future.

### Planned Structure

When complete, this directory will likely contain:

- **Packer Template (`.pkr.hcl`)**: The main Packer file defining the build sources, provisioners, and post-processors.
- **`http/` directory**: To serve the `user-data` and `meta-data` files to the virtual machine during the build process.
- **`scripts/` directory**: For any shell scripts that need to be run by Packer provisioners inside the image.
- **`output/` directory**: The destination for the final, provisioned `.img` file.
