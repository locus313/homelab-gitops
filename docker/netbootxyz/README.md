# NetbootXYZ

NetbootXYZ is a way to PXE boot various operating system installers or utilities from a single tool over the network. It provides a convenient way to boot multiple ISOs and tools without physical media.

## Features

- PXE boot menu with multiple OS options
- Web-based management interface
- Custom menu creation
- Support for various Linux distributions
- Windows PE environments
- Utility and rescue tools
- Local ISO hosting
- Custom boot entries

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `TZ`: Your timezone
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `NGINX_PORT`: Internal nginx port
   - `WEB_APP_PORT`: Web application port

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Network Ports

This service uses several ports:
- **69/UDP**: TFTP server for PXE boot
- **8080**: HTTP server (mapped internally)
- **3000**: Web management interface (via Traefik)

## Access

- Web Interface: `https://netbootxyz.yourdomain.com` (if using Traefik)
- Direct Access: `http://your-server-ip:8080`

## PXE Boot Setup

To use NetbootXYZ for PXE booting:

1. Configure your DHCP server with:
   - **Option 66** (Boot Server): IP address of your NetbootXYZ server
   - **Option 67** (Boot Filename): `netboot.xyz.kpxe` (for legacy) or `netboot.xyz.efi` (for UEFI)

2. Ensure client machines are configured to boot from network

## Initial Setup

1. Access the web management interface
2. Configure local menu options
3. Upload custom ISOs to the assets directory
4. Create custom boot entries
5. Test PXE boot functionality

## Custom Assets

You can add custom ISOs and tools:
- Assets Directory: `${DOCKER_BASE_PATH}/netbootxyz/assets`

Place your custom ISOs and files here to make them available via the boot menu.

## Available Boot Options

NetbootXYZ provides access to:
- **Linux Distributions**: Ubuntu, CentOS, Fedora, Debian, and more
- **Utility Tools**: System rescue, hardware testing, antivirus
- **Windows**: Windows PE environments
- **Custom**: Your own uploaded ISOs and tools

## Volumes

- Config: `${DOCKER_BASE_PATH}/netbootxyz/config` - NetbootXYZ configuration
- Assets: `${DOCKER_BASE_PATH}/netbootxyz/assets` - Custom ISOs and tools

## Network

This service is configured to use the `proxynet` external network for Traefik integration, with additional port mappings for PXE functionality.

## NetbootXYZ Image

This deployment uses the official NetbootXYZ image (`ghcr.io/netbootxyz/netbootxyz:0.7.6-nbxyz4`) which provides:

- Comprehensive boot menu options
- Regular updates with new distributions
- Web-based configuration interface
- Support for custom boot entries
