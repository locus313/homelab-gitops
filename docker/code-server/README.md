# Code Server

Code Server provides a browser-based Visual Studio Code experience, allowing you to code from anywhere. This setup includes Tailscale integration for secure remote access.

## Features

- Full VS Code experience in the browser
- Remote development capabilities
- Extension support
- Integrated terminal
- Git integration
- Tailscale VPN integration for secure access
- Docker access for containerized development

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

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Access via Tailscale network after configuration
- Local access may be available depending on configuration

## Services Included

- **Code Server**: VS Code web interface
- **Tailscale**: VPN tunnel for secure access

## Initial Setup

1. Configure Tailscale authentication
2. Access the interface using your configured credentials
3. Install desired VS Code extensions
4. Configure your development environment

## Volumes

- Config: `${DOCKER_BASE_PATH}/code-server` - Contains Code Server configuration
- Workspace: Custom workspace directory with initialization scripts
- Docker Socket: `/var/run/docker.sock` - Docker integration for container management
- Tailscale Config: `${DOCKER_BASE_PATH}/code-server/tailscale/config` - Tailscale configuration

## Security

This setup uses Tailscale for secure network access. Make sure to:
- Keep your Tailscale auth key secure
- Use strong passwords for Code Server access
- Regularly update the container images

## LinuxServer.io Image

This deployment uses the official LinuxServer.io Code Server image (`lscr.io/linuxserver/code-server:4.103.1`) which provides:

- Regular security updates
- Multi-architecture support
- Consistent user/group ID handling
- Clear documentation and support
