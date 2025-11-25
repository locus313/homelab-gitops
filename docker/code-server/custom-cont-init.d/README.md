# Custom Initialization Scripts

This directory contains custom initialization scripts that run during container startup to install additional development tools that aren't available via LinuxServer docker-mods.

## Scripts

### install-additional-tools.sh

Installs development tools that require special installation methods:

- **1Password CLI** - Installed from official 1Password repository
- **Packer** - Installed from HashiCorp repository
- **AWS Session Manager Plugin** - Downloaded and installed from AWS
- **aws-vault** - Downloaded from GitHub releases
- **tfenv** - Cloned from GitHub, installs multiple Terraform versions
- **lacework-cli** - Installed via Homebrew (if available)
- **k9s** - Installed via Homebrew (if available)

The script also configures Docker socket permissions for the `abc` user.

## How It Works

LinuxServer.io containers support custom initialization scripts in `/custom-cont-init.d/`. Scripts in this directory:

1. Are executed during container startup
2. Run before the main service starts
3. Should be executable (`chmod +x`)
4. Use idempotent checks (only install if tool is missing)

## Modifying the Script

To add new tools or modify installation:

1. Edit `install-additional-tools.sh`
2. Use `command -v` checks to make installations idempotent
3. Test by recreating the container: `docker compose up -d --force-recreate`

## Why Not Use Docker Mods?

These tools require one of the following:
- Custom repository configuration (1Password, Packer)
- Binary downloads from external sources (aws-vault, Session Manager)
- Git cloning and post-install configuration (tfenv)
- Homebrew installation (lacework-cli, k9s)

Docker-mods are better suited for tools available in standard package repositories or simple installations.
