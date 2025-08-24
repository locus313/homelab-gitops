# Watchtower

Watchtower is a container-based solution for automating Docker container base image updates. It monitors running containers and automatically updates them when newer versions of their base images are available.

## Features

- Automatic container updates
- Rolling updates with zero downtime
- Notification support (email, Slack, etc.)
- Cleanup of old images
- Monitoring specific containers or all containers
- Scheduling capabilities
- Security-focused updates

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `WATCHTOWER_CLEANUP`: Enable/disable cleanup of old images after updates

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## How It Works

Watchtower:
1. Monitors running containers for base image updates
2. Pulls new images when available
3. Stops the old container gracefully
4. Starts a new container with the updated image
5. Optionally cleans up old images

## Update Behavior

- **Automatic Updates**: Watchtower will automatically update containers by default
- **Cleanup**: When `WATCHTOWER_CLEANUP=true`, old images are removed after successful updates
- **Rolling Updates**: Containers are updated one at a time to minimize service disruption

## Excluding Containers

To prevent Watchtower from updating specific containers, add this label to those containers:
```yaml
labels:
  - com.centurylinklabs.watchtower.enable=false
```

## Monitoring Specific Containers

To monitor only specific containers, add this label:
```yaml
labels:
  - com.centurylinklabs.watchtower.enable=true
```

## Scheduling

Watchtower runs continuously by default. You can configure it to run on a schedule by adding environment variables:
- `WATCHTOWER_SCHEDULE`: Cron expression for update schedule
- `WATCHTOWER_RUN_ONCE`: Run once and exit

## Notifications

Configure notifications by adding environment variables:
- `WATCHTOWER_NOTIFICATIONS`: Enable notifications
- `WATCHTOWER_NOTIFICATION_EMAIL_*`: Email settings
- `WATCHTOWER_NOTIFICATION_SLACK_*`: Slack webhook settings

## Security Considerations

- Watchtower has access to the Docker socket for container management
- Only update containers from trusted registries
- Consider using image digests for critical containers
- Monitor logs for update activities

## Volumes

- Docker Socket: `/var/run/docker.sock` - Required for Docker container management

## Network

This service is configured to use the `proxynet` external network for consistency with other services.

## Best Practices

1. **Test Updates**: Use staging environments before production
2. **Backup Data**: Ensure data volumes are backed up before updates
3. **Monitor Logs**: Check Watchtower logs for update status
4. **Selective Updates**: Consider excluding critical containers from automatic updates
5. **Image Pinning**: Use specific tags for containers that shouldn't auto-update

## Watchtower Image

This deployment uses the official Watchtower image (`containrrr/watchtower`) which provides:

- Reliable container update automation
- Extensive configuration options
- Active community support
- Regular security updates
- Comprehensive logging and monitoring
