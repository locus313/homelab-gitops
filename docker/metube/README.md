# MeTube

MeTube is a web-based YouTube downloader that allows you to download videos and audio from YouTube and other supported platforms. It provides a simple interface for managing downloads.

## Features

- YouTube and multi-platform video downloading
- Audio-only download options
- Multiple quality options
- Playlist support
- Custom output templates
- Progress monitoring
- Web-based interface
- Batch downloads
- Format conversion options

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `UMASK`: File creation permissions mask
   - `OUTPUT_TEMPLATE`: Custom filename template for downloads
   - `YTDL_OPTIONS`: Additional yt-dlp options

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://metube.yourdomain.com` (if using Traefik)

## Usage

1. Access the web interface
2. Paste YouTube or supported platform URLs
3. Select desired quality and format
4. Choose download location
5. Monitor download progress

## Download Storage

Downloaded files are stored in:
- Output Directory: `/mnt/h-syn-1_media/Videos/converted`

## Supported Platforms

MeTube supports downloading from:
- YouTube
- Vimeo
- Dailymotion
- SoundCloud
- And many other platforms supported by yt-dlp

## Output Templates

Customize filename patterns using the `OUTPUT_TEMPLATE` environment variable. Examples:
- `%(title)s.%(ext)s` - Video title with extension
- `%(uploader)s - %(title)s.%(ext)s` - Include uploader name
- `%(upload_date)s - %(title)s.%(ext)s` - Include upload date

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## Legal Notice

Please ensure you comply with the terms of service of the platforms you're downloading from and respect copyright laws in your jurisdiction.

## MeTube Image

This deployment uses the official MeTube image (`ghcr.io/alexta69/metube:2025.08.22`) which provides:

- Regular updates with latest yt-dlp
- Web interface for easy management
- Support for multiple download formats
- Progress tracking and queue management
