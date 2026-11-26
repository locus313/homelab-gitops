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
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `MEDIA_PATH` and `BACKUP_PATH`: Host paths for media and backups
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `UMASK`: File creation permissions mask
   - `TZ`: Your timezone

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
- Input Storage: `${MEDIA_PATH}` mounted at `/storage/Media`
- Backup Storage: `${BACKUP_PATH}` mounted at `/storage/Backups`
- Output Directory: `${MEDIA_PATH}/Videos/temp/Output` mounted at `/output`

## Initial Setup

1. Access the web interface
2. Configure input and output directories
3. Select video files for conversion
4. Choose appropriate presets or custom settings
5. Start transcoding jobs

## Volumes

- Config: `${DOCKER_BASE_PATH}/handbrake` - Contains HandBrake configuration and watch folders
- Media and backup storage: `${MEDIA_PATH}` and `${BACKUP_PATH}`

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## jlesage Image

This deployment uses the jlesage HandBrake image (`ghcr.io/jlesage/handbrake:v26.09.1`) which provides:

- Web-based interface
- VNC access capabilities
- Automatic video conversion features
- Watch folder functionality
- Regular updates and maintenance
