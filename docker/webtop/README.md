# Webtop

Webtop is a Linux desktop environment running in a browser, powered by LinuxServer.io. It provides a full desktop experience accessible through a web browser, perfect for remote access and development tasks.

## Features

- Full Linux desktop environment in the browser
- Multiple desktop environments available (KDE, XFCE, MATE, i3)
- Built-in applications and development tools
- Remote desktop access via web browser
- File manager and terminal access
- Supports multiple users and sessions
- **Hardware GPU acceleration support (DRI3)**
- Custom application installation
- Docker-in-Docker capabilities

## Configuration

The following environment variables can be configured in your `.env` file:

- `PUID`: User ID for file permissions (default: 1000)
- `PGID`: Group ID for file permissions (default: 1000)
- `TZ`: Timezone (e.g., America/New_York)
- `SUBFOLDER`: Optional subfolder for reverse proxy setup
- `TITLE`: Custom title for the desktop environment
- `DRINODE`: Optional specific GPU device for DRI3 acceleration
- `CUSTOM_USER`: Username for HTTP Basic Authentication (default: abc)
- `PASSWORD`: Password for HTTP Basic Authentication (leave empty to disable)
- `DOCKER_BASE_PATH`: Base path for Docker volumes
- `TRAEFIK_BASE_DOMAIN`: Base domain for Traefik routing

## GPU Acceleration

This configuration includes DRI3 GPU acceleration support by mounting `/dev/dri:/dev/dri`. This enables hardware-accelerated graphics for:

- **Supported GPU drivers**: Intel (i965/i915), AMD (AMDGPU/Radeon/ATI), NVIDIA (nouveau only)
- **Accelerated applications**: Games, video playback, 3D rendering, CAD software
- **Performance benefits**: Reduced CPU usage, smoother graphics, better video streaming

### GPU Selection
If you have multiple GPUs, you can specify which one to use with the `DRINODE` environment variable:
```bash
# Use a specific GPU
DRINODE=/dev/dri/renderD128
```

Leave `DRINODE` empty for automatic GPU detection.

## Security & Authentication

### Basic Authentication
Webtop includes optional HTTP Basic Authentication for securing access:

```bash
# Enable basic auth
CUSTOM_USER=admin
PASSWORD=your-secure-password

# Disable auth (not recommended for internet exposure)  
PASSWORD=
```

### Security Considerations
- **⚠️ Default setup**: No authentication by default - secure for trusted networks only
- **🌐 Internet exposure**: Always enable authentication when accessible from the internet
- **🔒 Strong passwords**: Use complex passwords for the `PASSWORD` variable
- **🛡️ Network isolation**: Consider additional security layers like VPN or Traefik auth
- **🔑 Privileged access**: Web interface includes terminal with passwordless sudo access

### Recommended Security Setup
1. **Enable basic auth**: Set strong `CUSTOM_USER` and `PASSWORD`
2. **Use HTTPS**: Traefik provides automatic SSL certificates
3. **Network segmentation**: Consider firewall rules or VPN access
4. **Regular updates**: Keep container images updated for security patches

## Deployment

### Using Portainer
1. In Portainer, create a new stack
2. Use the Git repository option
3. Set the repository path to: `docker/webtop`
4. Configure your environment variables
5. Deploy the stack

### Manual Deployment
```bash
cd docker/webtop
docker compose up -d
```

## Access

- **Web Interface**: `https://webtop.your-domain.com` (with Traefik)
- **Direct Access**: `http://your-server-ip:3000`

## Usage

1. Access the web interface through your browser
2. The default desktop environment will load
3. Use the file manager to access mounted volumes
4. Install additional applications as needed
5. Multiple browser tabs allow multiple sessions

## Storage

- Configuration and user data: `${DOCKER_BASE_PATH}/webtop`
- Docker socket mounted for container management access

## Security Notes

- The container runs with `seccomp:unconfined` for full desktop functionality
- Docker socket is mounted for development purposes
- Consider network isolation for production use
- Regular updates recommended for security patches

## Customization

- Desktop environment can be changed via image tags
- Custom applications can be installed through the desktop
- Persistent storage ensures configurations survive container restarts
- Volume mounts can be added for accessing host files
