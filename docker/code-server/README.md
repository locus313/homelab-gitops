# Code Server

Code Server provides a browser-based Visual Studio Code experience, allowing you to code from anywhere. This setup includes Tailscale integration for secure remote access.

## Table of Contents

- [Features](#features)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Docker Mods](#docker-mods)
- [Tool Verification](#tool-verification)
- [Terraform Version Management](#terraform-version-management)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Security](#security)

## Features

- Full VS Code experience in the browser
- Remote development capabilities
- Extension support
- Integrated terminal
- Git integration
- Tailscale VPN integration for secure access
- Docker access for containerized development
- Pre-installed development tools:
  - PowerShell, Docker CLI, AWS CLI, Terraform, Python3 (via docker-mods)
  - System utilities: direnv, vim, wget, make, clang, git
  - AWS tools: aws-vault, Session Manager Plugin
  - HashiCorp tools: Packer, tfenv (Terraform version manager)
  - Security: 1Password CLI, lacework-cli
  - Kubernetes: k9s

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `TZ`: Your timezone
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `PASSWORD`: Access password for Code Server
   - `SUDO_PASSWORD`: Sudo password for terminal operations
   - `DEFAULT_WORKSPACE`: Default workspace directory
   - `TS_AUTHKEY`: Tailscale authentication key
   - `TS_EXTRA_ARGS`: Additional Tailscale arguments
   - `TS_SERVE_CONFIG`: Tailscale serve configuration
   - `TS_STATE_DIR`: Tailscale state directory
   - `TS_USERSPACE`: Tailscale userspace mode

3. Deploy the service (see [Deployment](#deployment) section for details)

## Deployment

### Initial Deployment
```bash
cd docker/code-server
docker compose up -d
```

### Update After Configuration Changes
```bash
docker compose up -d --force-recreate
```

### View Logs
```bash
docker logs -f code-server
```

### Monitor Installation
Watch the logs during first startup to see docker-mods installation and custom script execution.

## Access

- **Via Tailscale**: Access through your Tailscale network after configuration
- **Via Traefik**: If configured, access via `code-server.your-domain.com`
- **Local**: Depends on your network configuration

## Services Included

- **Code Server**: VS Code web interface
- **Tailscale**: VPN tunnel for secure access

## Initial Setup

1. Configure Tailscale authentication
2. Access the interface using your configured credentials
3. Install desired VS Code extensions
4. Configure your development environment

## Volumes

- **Config**: `${DOCKER_BASE_PATH}/code-server` - Contains Code Server configuration
- **Docker Socket**: `/var/run/docker.sock` - Docker integration for container management
- **Tailscale Config**: `${DOCKER_BASE_PATH}/code-server/tailscale/config` - Tailscale configuration
- **Custom Init Scripts**: `./custom-cont-init.d` - Local initialization scripts (read-only)

## Docker Mods

This deployment uses LinuxServer.io docker-mods to install development tools automatically:

### Core Development Tools (via docker-mods)
- `linuxserver/mods:code-server-powershell` - PowerShell Core
- `linuxserver/mods:universal-docker` - Docker CLI
- `linuxserver/mods:code-server-awscli` - AWS CLI v2
- `linuxserver/mods:code-server-terraform` - Terraform
- `linuxserver/mods:code-server-python3` - Python 3

### System Packages (via universal-package-install)
- acl, apt-transport-https, direnv, gpg, make
- software-properties-common, vim, wget, unzip, clang, git

### Additional Tools (via custom init script)
The following tools are installed via a custom initialization script in `custom-cont-init.d/`:

- **1Password CLI** - Secure secrets management
- **Packer** - Image building automation
- **AWS Session Manager Plugin** - AWS Systems Manager sessions
- **aws-vault** - AWS credential management
- **tfenv** - Terraform version manager
  - Pre-installed versions: 0.12.31, 0.14.3, 0.14.11, 1.1.9, 1.2.2, 1.3.9, 1.4.2
- **lacework-cli** - Security platform CLI (requires Homebrew)
- **k9s** - Kubernetes CLI manager (requires Homebrew)

Additional mods can be added by updating the `DOCKER_MODS` environment variable in `docker-compose.yml`. See the [LinuxServer docker-mods list](https://github.com/linuxserver/docker-mods/blob/master/mod-list.yml) for available options.

## Tool Verification

After deployment, verify installed tools:

```bash
# Exec into container
docker exec -it code-server bash

# Check versions
powershell --version
docker --version
aws --version
terraform --version
python3 --version
op --version
packer --version
direnv --version
```

## Terraform Version Management

This setup includes tfenv for managing multiple Terraform versions:

### List Installed Versions
```bash
/config/.tfenv/bin/tfenv list
```

### Install New Version
```bash
/config/.tfenv/bin/tfenv install 1.5.0
```

### Switch Version
```bash
/config/.tfenv/bin/tfenv use 1.5.0
```

### Pre-installed Versions
- 0.12.31, 0.14.3, 0.14.11, 1.1.9, 1.2.2, 1.3.9, 1.4.2

## Customization

### Add Docker-Mod
Edit `docker-compose.yml` and add to the `DOCKER_MODS` environment variable:
```yaml
DOCKER_MODS: >-
  linuxserver/mods:code-server-powershell|
  linuxserver/mods:code-server-nodejs|
  linuxserver/mods:universal-docker
```

Browse available mods: https://github.com/linuxserver/docker-mods/blob/master/mod-list.yml

### Add System Package
Edit the `INSTALL_PACKAGES` environment variable in `docker-compose.yml`:
```yaml
INSTALL_PACKAGES: >-
  acl|vim|wget|your-new-package
```

### Add Custom Tool
Edit `custom-cont-init.d/install-additional-tools.sh`:
```bash
if ! command -v your-tool &> /dev/null; then
    echo "**** Installing your-tool ****"
    # Installation commands here
fi
```

## Troubleshooting

### Container Won't Start
```bash
docker logs code-server
# Look for errors in mod installation or script execution
```

### Tool Not Found
```bash
# Check if it was supposed to be installed
docker exec -it code-server bash
cat /custom-cont-init.d/install-additional-tools.sh | grep -i "tool-name"

# Re-run installation
docker compose up -d --force-recreate
```

### Permission Denied on docker.sock
```bash
# The script should handle this automatically, but if issues persist:
docker exec -it code-server bash
sudo setfacl --modify user:abc:rw /var/run/docker.sock
```

### Docker Socket Verification
```bash
# Check docker access
docker exec -it code-server docker ps

# Verify socket permissions
docker exec -it code-server ls -la /var/run/docker.sock

# Check user groups
docker exec -it code-server id abc
```

### Updates Not Applying
```bash
# Force recreate container
docker compose down
docker compose up -d --force-recreate

# Or pull new image first
docker compose pull
docker compose up -d --force-recreate
```

## Security

This setup uses Tailscale for secure network access. Make sure to:
- Change default passwords in `.env`
- Keep your Tailscale auth key secure
- Use strong passwords for Code Server access
- Regularly update container: `docker compose pull && docker compose up -d`
- Monitor logs for unusual activity: `docker logs code-server`

## LinuxServer.io Image

This deployment uses the official LinuxServer.io Code Server image (`lscr.io/linuxserver/code-server:4.106.2`) which provides:

- Regular security updates
- Multi-architecture support
- Consistent user/group ID handling
- Clear documentation and support
- Docker-mods compatibility for easy extension

## Architecture Notes

### Installation Layers
This deployment uses a three-layer approach for tool installation:

1. **Docker Mods (Official)** - Pre-built container extensions for core tools
   - Fastest installation, maintained by LinuxServer.io
   - PowerShell, Docker CLI, AWS CLI, Terraform, Python3

2. **Package Install (Dynamic)** - System packages via apt during startup
   - Simple packages available in Ubuntu repositories
   - acl, direnv, vim, wget, make, clang, git, etc.

3. **Custom Script (Complex)** - Tools requiring special installation
   - Custom repositories, GitHub releases, or complex setup
   - 1Password CLI, Packer, aws-vault, tfenv, k9s, etc.

### Benefits of This Approach
- **No External Dependencies**: All scripts are local to the repository
- **Maintainability**: Official docker-mods are maintained by LinuxServer.io
- **Speed**: Mods use pre-built layers for faster startup
- **Flexibility**: Easy to add/remove tools by editing compose file
- **Idempotent**: Scripts check before installing, safe to restart
