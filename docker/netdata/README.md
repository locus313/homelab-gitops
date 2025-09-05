# Netdata

Netdata is a real-time performance monitoring tool that provides comprehensive system monitoring with beautiful visualizations.

## Features

- Real-time system monitoring
- Docker container monitoring
- Network, CPU, memory, disk monitoring
- Custom dashboards and alerts
- Integration with Netdata Cloud
- Low resource overhead

## Configuration

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your configuration:
   - Set `DOCKER_BASE_PATH` to your Docker data directory
   - Configure Netdata Cloud integration (optional)

3. **Important**: Get your Netdata Cloud credentials from [app.netdata.cloud](https://app.netdata.cloud):
   - Sign up for a free account
   - Create a new space or join an existing one
   - Get your claim token and room ID from the "Connect Nodes" section

## Deployment

```bash
docker compose up -d
```

## Access

Since Netdata uses host networking for optimal system monitoring:
- **Web Interface**: `http://your-server-ip:19999`
- **Default Port**: 19999

## Architecture Notes

**Why Host Networking?**
Netdata requires host networking mode to properly monitor system resources. This means:
- It cannot be proxied through Traefik like other services
- Direct access via IP:port is required
- Enhanced system monitoring capabilities

**Security Considerations:**
- Uses privileged capabilities (`SYS_PTRACE`, `SYS_ADMIN`) for deep system monitoring
- Has read-only access to host filesystems
- Monitors Docker socket for container metrics

## Configuration Files

Netdata configuration is stored in `${DOCKER_BASE_PATH}/netdata/config/`. You can customize:
- `netdata.conf` - Main configuration
- `health.d/` - Health monitoring alerts
- `python.d/` - Python plugin configurations

## Netdata Cloud Integration

If you configure Netdata Cloud:
- Real-time monitoring from anywhere
- Alerts and notifications
- Multi-node management
- Historical data retention

To disable cloud features, uncomment `DO_NOT_TRACK=1` in your `.env` file.

## Troubleshooting

**Container won't start:**
- Ensure Docker has sufficient privileges
- Check that port 19999 isn't already in use
- Verify volume mount permissions

**Missing metrics:**
- Confirm all required volumes are mounted
- Check container logs: `docker logs netdata`
- Verify host system compatibility

**Performance impact:**
- Netdata is designed to be lightweight
- Monitor resource usage if running on constrained systems
- Adjust collection frequency in netdata.conf if needed

## Links

- [Official Documentation](https://learn.netdata.cloud/)
- [GitHub Repository](https://github.com/netdata/netdata)
- [Netdata Cloud](https://app.netdata.cloud/)
- [Configuration Guide](https://learn.netdata.cloud/docs/configure)
