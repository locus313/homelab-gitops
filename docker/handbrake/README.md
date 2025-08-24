# HandBrake

HandBrake is a powerful video transcoder that can convert video files between different formats and qualities. This web-based version provides an easy-to-use interface for video conversion tasks.

## Features

- Web-based interface for video transcoding
- Support for multiple input/output formats
- Hardware acceleration support (Intel GPU)
- Batch processing capabilities
- Quality and compression presets
- Custom encoding settings
- Progress monitoring

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `USER_ID` and `GROUP_ID`: User and group IDs for file permissions
   - `TZ`: Your timezone
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `UMASK`: File creation permissions mask

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://handbrake.yourdomain.com` (if using Traefik)

## Hardware Acceleration

This setup includes Intel GPU hardware acceleration support via `/dev/dri` device mapping for faster video encoding.

## Storage

The service is configured with the following volume mappings:
- Input Storage: `/mnt/h-syn-1_media` - Media files for conversion
- Backup Storage: `/mnt/h-syn-1_backups` - Additional storage
- Output Directory: `/mnt/h-syn-1_media/Videos/temp/Output` - Converted files destination

## Initial Setup

1. Access the web interface
2. Configure input and output directories
3. Select video files for conversion
4. Choose appropriate presets or custom settings
5. Start transcoding jobs

## Volumes

- Config: `${DOCKER_BASE_PATH}/handbrake` - Contains HandBrake configuration and watch folders
- Media Storage: Various mounted directories for input and output files

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## jlesage Image

This deployment uses the jlesage HandBrake image (`ghcr.io/jlesage/handbrake:v25.07.2`) which provides:

- Web-based interface
- VNC access capabilities
- Automatic video conversion features
- Watch folder functionality
- Regular updates and maintenance
