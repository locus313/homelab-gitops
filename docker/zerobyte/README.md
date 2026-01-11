# Zerobyte

Powerful backup automation for your remote storage. Built on top of Restic, Zerobyte provides a modern web interface to schedule, manage, and monitor encrypted backups across multiple storage backends.

## Features

- **Automated Backups**: End-to-end encryption, compression, and retention policies powered by Restic
- **Flexible Scheduling**: Fine-grained control over backup jobs with cron-like scheduling
- **Multi-Protocol Support**: Backup from NFS, SMB, WebDAV, SFTP, or local directories
- **Multiple Repository Types**: Store backups on local disk, S3, GCS, Azure, or 40+ cloud providers via rclone
- **Data Deduplication**: Efficient storage with block-level deduplication
- **Easy Restoration**: Browse and restore individual files or entire directories
- **Monitoring**: Track backup job status, size, and success/failure metrics

## Prerequisites

- Docker and Docker Compose installed
- Traefik configured and running (see [traefik directory](../traefik))
- `proxynet` Docker network created: `docker network create proxynet`

## Important Security Note

⚠️ **DO NOT** expose Zerobyte directly to the internet without proper authentication. This service requires `SYS_ADMIN` capability and FUSE device access for remote mount functionality. Always use it behind Traefik with proper access controls or on a private network.

## Setup Instructions

1. **Copy environment template**:
   ```bash
   cd docker/zerobyte
   cp .env.example .env
   ```

2. **Configure environment variables**:
   - Edit `.env` with your settings
   - Set `DOCKER_BASE_PATH` to your Docker data directory
   - Configure `TRAEFIK_BASE_DOMAIN` for your domain
   - Adjust `TZ` to your timezone (crucial for accurate backup scheduling)

3. **Start the service**:
   ```bash
   docker compose up -d
   ```

4. **Access Zerobyte**:
   - Navigate to `https://zerobyte.YOUR_DOMAIN`
   - Complete initial setup through the web interface

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Internal port for web interface and API | `4096` |
| `RESTIC_HOSTNAME` | Hostname used by Restic when creating snapshots | `zerobyte` |
| `TZ` | Timezone for accurate backup scheduling | `America/Los_Angeles` |
| `LOG_LEVEL` | Logging verbosity (debug, info, warn, error) | `info` |
| `SERVER_IDLE_TIMEOUT` | Idle timeout for the server in seconds | `60` |
| `TRUSTED_ORIGINS` | Comma-separated list of trusted origins for CORS | (empty) |

### Capabilities and Devices

This service requires:
- **`SYS_ADMIN` capability**: Needed to mount remote shares (NFS, SMB, WebDAV, SFTP)
- **`/dev/fuse` device**: Required for FUSE filesystem operations

### Simplified Setup (No Remote Mounts)

If you only need to back up locally mounted folders and don't require remote share mounting, you can improve security by removing the `SYS_ADMIN` capability and FUSE device:

1. Edit `docker-compose.yml` and remove:
   ```yaml
   cap_add:
     - SYS_ADMIN
   devices:
     - /dev/fuse:/dev/fuse
   ```

2. Mount local directories into the container:
   ```yaml
   volumes:
     - /path/to/backup:/data
   ```

**Trade-offs**:
- ✅ Improved security by reducing container capabilities
- ✅ Support for local directories and all repository types
- ❌ Cannot mount NFS, SMB, WebDAV, or SFTP shares directly

### Secret References

Zerobyte supports dynamic secret resolution for sensitive fields (passwords, access keys):

- `env://VAR_NAME`: Reads from environment variable
- `file://SECRET_NAME`: Reads from `/run/secrets/SECRET_NAME` (Docker Secrets)

Example: When configuring an S3 repository, set the Secret Access Key to `env://S3_SECRET_KEY` and provide that variable in your docker-compose.yml.

## Using Zerobyte

### 1. Adding a Volume

Volumes represent the source data you want to back up. Zerobyte supports:

- **NFS**: Network File System shares
- **SMB/CIFS**: Windows file shares
- **WebDAV**: Web-based file sharing
- **SFTP**: SSH file transfer protocol
- **Local Directories**: Mounted paths in the container

For local directories, mount them in `docker-compose.yml`:

```yaml
volumes:
  - /path/to/your/data:/mydata
```

Then create a "Directory" type volume in the web interface using `/mydata` as the path.

### 2. Creating a Repository

Repositories store your encrypted backups. Supported backends:

- **Local**: Disk storage (within `/var/lib/zerobyte/repositories/` or mounted paths)
- **S3**: Amazon S3, MinIO, Wasabi, DigitalOcean Spaces, etc.
- **GCS**: Google Cloud Storage
- **Azure**: Azure Blob Storage
- **rclone**: 40+ cloud providers (Google Drive, Dropbox, OneDrive, etc.)

#### Using rclone for Cloud Storage

To use rclone with cloud providers:

1. Install rclone on your host: `curl https://rclone.org/install.sh | sudo bash`
2. Configure your cloud storage: `rclone config`
3. Mount the rclone config in docker-compose.yml:
   ```yaml
   volumes:
     - ~/.config/rclone:/root/.config/rclone
   ```
4. Restart the container and select your rclone remote in Zerobyte

### 3. Creating a Backup Job

Backup jobs define schedules and retention policies:

- **Schedule**: Cron-like expressions for automated backups
- **Retention**: Rules for how long to keep backups (daily, weekly, monthly, yearly)
- **Paths**: Specific files/directories to include or exclude
- **Notifications**: Optional alerts on success/failure

### 4. Restoring Data

Browse backup snapshots and restore individual files or entire directories through the web interface. Data is restored to original locations by default.

## Storage Considerations

⚠️ **Important**: Do not point `/var/lib/zerobyte` to a network share. This will cause:
- Permission issues with container operations
- Severe performance degradation
- Potential backup failures

Always use local storage for the Zerobyte data directory.

## Troubleshooting

### Container fails to start
- Verify `proxynet` network exists: `docker network create proxynet`
- Check if `/dev/fuse` is available on host system
- Review container logs: `docker logs zerobyte`

### Cannot mount remote shares
- Ensure `SYS_ADMIN` capability is enabled
- Verify `/dev/fuse` device is mounted
- Check network connectivity to remote share
- Review mount credentials and paths

### Backup jobs fail
- Check volume connectivity and permissions
- Verify repository credentials are correct
- Review backup job logs in the web interface
- Check available disk space on repository backend

### Web interface not accessible
- Confirm Traefik is running and configured correctly
- Verify DNS points to your server
- Check Traefik logs: `docker logs traefik`
- Inspect Traefik dashboard for service discovery

## Documentation

- [Official Documentation](https://github.com/nicotsx/zerobyte)
- [Troubleshooting Guide](https://github.com/nicotsx/zerobyte/blob/main/TROUBLESHOOTING.md)
- [Restic Documentation](https://restic.readthedocs.io/)
- [rclone Providers](https://rclone.org/)

## Version Information

- **Current Image**: `ghcr.io/nicotsx/zerobyte:v0.21.1`
- **Latest Release**: Check [GitHub Releases](https://github.com/nicotsx/zerobyte/releases)

## License

Zerobyte is licensed under AGPL-3.0. See the [project repository](https://github.com/nicotsx/zerobyte) for details.
