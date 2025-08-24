# iVentoy

iVentoy is a PXE boot server that allows you to boot ISO files over the network. It provides an easy way to deploy operating systems and utilities to multiple machines without physical media.

## Features

- PXE boot server for network installations
- ISO file management and deployment
- Web-based management interface
- Support for multiple operating systems
- DHCP proxy mode
- Legacy and UEFI boot support
- Multiple client support
- Remote boot capabilities

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `DOCKER_BASE_PATH`: Base path for Docker volumes

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Network Ports

This service requires several network ports to function properly:
- **26000**: Management web interface
- **16000**: HTTP server for boot files
- **10809**: Additional service port
- **69/UDP**: TFTP server for PXE boot

## Access

- Web Interface: `http://your-server-ip:26000`

## Initial Setup

1. Access the web management interface
2. Upload ISO files to the `/iso` directory
3. Configure network settings for your environment
4. Set up DHCP options on your network (option 66 and 67)
5. Configure client machines to boot from network

## ISO Management

Place your ISO files in the mounted ISO directory:
- ISO Storage: `${DOCKER_BASE_PATH}/iventoy/iso`

Supported ISO types include:
- Linux distributions (Ubuntu, CentOS, Fedora, etc.)
- Windows installation media
- Rescue and utility disks
- Custom boot images

## Network Configuration

For proper PXE booting, configure your DHCP server with:
- **Option 66** (Boot Server): IP address of the iVentoy server
- **Option 67** (Boot Filename): Boot file name provided by iVentoy

## Volumes

- ISO Files: `${DOCKER_BASE_PATH}/iventoy/iso` - Storage for boot ISO files
- Data: `${DOCKER_BASE_PATH}/iventoy/data` - iVentoy configuration and data
- Logs: `${DOCKER_BASE_PATH}/iventoy/log` - Service logs

## Security

This service runs in privileged mode for network access. Ensure:
- Proper firewall configuration
- Network segmentation if needed
- Regular updates of ISO files
- Monitor access logs

## Network

This service is configured to use the `proxynet` external network and requires direct port access for PXE functionality.
