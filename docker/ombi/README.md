# Ombi

Ombi is a web application that gives your shared Plex or Emby users the ability to request content by themselves. Ombi can be linked to multiple TV Show and Movie DVR tools to create a seamless end-to-end experience for your users.

## Features

- Request movies and TV shows
- User management system
- Integration with Plex, Emby, and Jellyfin
- Integration with Sonarr and Radarr
- Email notifications
- Mobile responsive design
- Multi-language support

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

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://ombi.yourdomain.com` (if using Traefik)

## Initial Setup

1. Access the web interface
2. Complete the setup wizard
3. Connect to your Plex/Emby/Jellyfin server
4. Configure Sonarr/Radarr integration (optional)
5. Set up user permissions and email notifications

## Volumes

- Config: `${DOCKER_BASE_PATH}/ombi/config` - Contains Ombi configuration and database

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## LinuxServer.io Image

This deployment uses the official LinuxServer.io Ombi image (`lscr.io/linuxserver/ombi:latest`) which provides:

- Regular security updates
- Multi-architecture support (x86-64, arm64, armhf)
- Consistent user/group ID handling
- Clear documentation and support
