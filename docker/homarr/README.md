# Homarr

Homarr is a customizable homelab dashboard that provides a centralized view of all your self-hosted services. It offers a clean interface with widgets, service monitoring, and Docker integration.

## Features

- Customizable dashboard layout
- Service status monitoring
- Docker container integration
- Weather widgets
- Calendar integration
- Media server integration
- Custom widgets and tiles
- Search functionality
- Mobile responsive design

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `SECRET_ENCRYPTION_KEY`: Encryption key for sensitive data

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://homarr.yourdomain.com` (if using Traefik)

## Docker Integration

This setup includes Docker socket access for container monitoring and management features. Homarr can display container status and basic management capabilities.

## Initial Setup

1. Access the web interface
2. Complete the initial configuration wizard
3. Add your services and configure tiles
4. Customize the dashboard layout
5. Configure widgets for weather, calendar, etc.
6. Set up service monitoring

## Features Configuration

- **Service Tiles**: Add links to your homelab services
- **Container Monitoring**: View Docker container status
- **Weather Widget**: Display local weather information
- **Calendar Integration**: Connect external calendars
- **Custom CSS**: Personalize the appearance

## Volumes

- AppData: `${DOCKER_BASE_PATH}/homarr/appdata` - Contains Homarr configuration and data
- Docker Socket: `/var/run/docker.sock` - Docker integration (optional)

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## Security

Make sure to:
- Use a strong `SECRET_ENCRYPTION_KEY`
- Limit Docker socket access if not needed
- Keep the container updated for security patches

## Homarr Labs Image

This deployment uses the official Homarr Labs image (`ghcr.io/homarr-labs/homarr:v1.34.0`) which provides:

- Regular feature updates
- Community support
- Comprehensive documentation
- Active development
