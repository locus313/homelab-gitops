# Beszel

Beszel is a lightweight server monitoring solution that provides real-time insights into your server's performance and health. It consists of a main hub for visualization and agents that collect metrics from your servers.

## Features

- Real-time server monitoring
- Lightweight resource usage
- Docker container monitoring
- Network and system metrics
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

## Network

This service is configured to use the `proxynet` external network for Traefik integration. The agent runs in host network mode for optimal system metrics collection.

## Security

The agent connects to the hub using a secure socket connection. Make sure to keep your `BESZEL_PUBLIC_KEY` secure and don't share it publicly.
