# Beszel

Beszel is a lightweight server monitoring solution that provides real-time insights into your server's performance and health. It consists of a main hub for visualization and agents that collect metrics from your servers.

## Features

- Real-time server monitoring
- Lightweight resource usage
- Docker container monitoring with exclude patterns
- Network and system metrics
- S.M.A.R.T. disk health monitoring (v0.15.0+)
- CPU per-core usage and state details (v0.15.3+)
- Intel GPU monitoring support
- Clean web interface
- Agent-based architecture
- Multi-server support

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `BESZEL_PUBLIC_KEY`: Public key for agent authentication
   - `EXCLUDE_CONTAINERS` (optional): Exclude containers from monitoring using glob patterns
   - `CONTAINER_DETAILS` (optional): Control access to container logs/info (default: true)
   - `INTEL_GPU_DEVICE` (optional): Specify Intel GPU device for monitoring

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://beszel.yourdomain.com` (if using Traefik)

## Services Included

- **Beszel Hub**: Main monitoring dashboard (port 8090)
- **Beszel Agent**: Metrics collection agent

## Initial Setup

1. Access the web interface to complete initial setup
2. Generate authentication keys for agents
3. Configure monitoring thresholds and alerts
4. Add additional servers by deploying agents

## Volumes

- Data: `${DOCKER_BASE_PATH}/beszel/data` - Contains Beszel configuration and database
- Socket: `${DOCKER_BASE_PATH}/beszel/socket` - Unix socket for hub-agent communication
- Agent Data: `${DOCKER_BASE_PATH}/beszel/agent_data` - Persistent agent data and cache

## Advanced Configuration

### Monitoring Additional Disks

To monitor additional disks or partitions, mount them in the agent container under `/extra-filesystems`:

```yaml
volumes:
  - /mnt/disk1/.beszel:/extra-filesystems/disk1:ro
  - /mnt/disk2/.beszel:/extra-filesystems/disk2:ro
```

### Excluding Containers

Use the `EXCLUDE_CONTAINERS` environment variable to exclude containers from monitoring:

```bash
# Exclude specific containers using glob patterns
EXCLUDE_CONTAINERS=*test*,nginx-proxy,temp-*
```

### Intel GPU Monitoring

Specify a custom Intel GPU device for monitoring:

```bash
INTEL_GPU_DEVICE=/dev/dri/card0
```

### Container Security

For enhanced security, you can disable access to container logs and detailed info:

```bash
CONTAINER_DETAILS=false
```

## Network

This service is configured to use the `proxynet` external network for Traefik integration. The agent runs in host network mode for optimal system metrics collection.

## Security

The agent connects to the hub using a secure socket connection. Make sure to keep your `BESZEL_PUBLIC_KEY` secure and don't share it publicly.
