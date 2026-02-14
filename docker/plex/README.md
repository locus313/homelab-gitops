# Plex

Plex is a media server that organizes your personal media collection and streams it to any device. It provides a comprehensive solution for managing and consuming your movies, TV shows, music, and photos.

## Features

- Media server with automatic organization
- Multi-platform client support
- Hardware-accelerated transcoding
- Remote access capabilities
- Subtitle support
- Live TV and DVR (with Plex Pass)
- Sharing with friends and family
- Mobile apps and smart TV apps
- Automatic metadata fetching

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `TZ`: Your timezone
   - `PLEX_CLAIM`: Plex claim token for initial setup (get from plex.tv/claim)

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `http://your-server-ip:32400/web`
- Remote Access: Available through plex.tv after setup

## Hardware Acceleration

This setup includes Intel GPU hardware acceleration support via `/dev/dri` device mapping for efficient video transcoding.

## Initial Setup

1. Obtain a claim token from https://plex.tv/claim
2. Add the token to your `.env` file as `PLEX_CLAIM`
3. Access the web interface within 4 minutes of starting the container
4. Complete the initial setup wizard
5. Add your media libraries

## Media Libraries

The service is configured with the following media directories:
- **Videos**: `/mnt/h-syn-1_media/Videos` - Movies and TV shows
- **Music**: `/mnt/h-syn-1_media/Music` - Music collection
- **Photos**: `/mnt/h-syn-1_media/Pictures` - Photo library
- **General Data**: `/mnt/h-syn-1_media` - Additional media storage

## Library Organization

For best results, organize your media as follows:
```
Videos/
├── Movies/
│   ├── Movie Name (Year)/
│   │   └── Movie Name (Year).mkv
│   └── ...
└── TV Shows/
    ├── TV Show Name/
    │   ├── Season 01/
    │   │   ├── S01E01 - Episode Name.mkv
    │   │   └── ...
    │   └── ...
    └── ...
```

## Volumes

- Config: `/docker/PlexMediaServer` - Plex configuration and metadata
- Transcode: `/docker/PlexMediaServer/transcode` - Temporary transcoding files
- Media: Various mounted directories for your media collection
- Time Sync: `/etc/localtime` - System time synchronization

## Network

This service uses host networking mode for optimal performance and easier setup with Plex's networking requirements.

## Performance

- Hardware transcoding is enabled with Intel GPU support
- Dedicated transcode directory for temporary files
- Host networking for optimal streaming performance

## Plex Pass Features

Consider a Plex Pass subscription for:
- Hardware transcoding
- Mobile sync
- Live TV and DVR
- Premium music features
- Early access to new features

## Official Plex Image

This deployment uses the official Plex image (`plexinc/pms-docker:1.43.0.10492-121068a07`) which provides:

- Official support from Plex Inc.
- Regular updates and security patches
- Optimized performance
- Full feature compatibility
