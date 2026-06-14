# Traefik

Traefik is a modern reverse proxy and load balancer that makes deploying microservices easy. It automatically discovers services and configures routing rules, providing SSL termination and load balancing.

## Features

- Automatic service discovery
- Let's Encrypt SSL certificate automation
- Load balancing and failover
- Middleware support (authentication, rate limiting, etc.)
- Web dashboard for monitoring
- Multiple backend support (Docker, Kubernetes, etc.)
- Health checks and circuit breakers
- Metrics and monitoring integration

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `TRAEFIK_BASE_DOMAIN`: Your base domain for services
   - `CLOUDNS_SUB_AUTH_ID`: CloudNS sub-authentication ID (for DNS challenges)
   - `CLOUDNS_AUTH_PASSWORD`: CloudNS authentication password

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

> [!NOTE]
> The Traefik dashboard and API are **disabled** in this deployment (`api.dashboard: false`). This is intentional — exposing the dashboard or API adds attack surface without operational need.

To inspect routing state or diagnose issues, use container logs:

```bash
docker logs -f traefik
tail -f ${DOCKER_BASE_PATH}/traefik/logs/traefik.log
tail -f ${DOCKER_BASE_PATH}/traefik/logs/access.log
```

## SSL Certificates

This setup uses Let's Encrypt with DNS challenges via CloudNS for automatic SSL certificate generation and renewal. Certificates are automatically obtained for:
- The Traefik dashboard
- All configured services
- Wildcard certificates (if configured)

## Configuration Files

The Traefik configuration is split into:
- **Static Configuration**: `config/traefik.yaml` - Main Traefik settings
- **Dynamic Configuration**: `config/dynamic/` - Service-specific routing rules

### Dynamic Configuration Files

- `dh01.yaml`: Configuration for dh01 service
- `storj-node-1.yaml`: Configuration for Storj node

## Service Discovery

Traefik automatically discovers services through:
- Docker labels on containers
- File-based configuration in the dynamic folder
- API configuration

### Docker Labels

Services use labels for automatic configuration:
```yaml
labels:
  - traefik.enable=true
  - traefik.http.services.myservice.loadbalancer.server.port=8080
  - traefik.http.routers.myservice.rule=Host(`myservice.${TRAEFIK_BASE_DOMAIN}`)
  - traefik.http.routers.myservice.entrypoints=websecure
  - traefik.http.routers.myservice.tls=true
  - traefik.http.routers.myservice.tls.certresolver=cloudns
```

## Entrypoints

- **web**: HTTP traffic (port 80) — redirects all requests to HTTPS
- **websecure**: HTTPS traffic (port 443) with HTTP/3 enabled

## What Is Configured

This deployment uses a minimal, security-focused configuration:

- HTTP → HTTPS redirect on all incoming requests
- DNS-01 TLS via CloudNS (`certresolver: cloudns`)
- Access and error logs written to `${DOCKER_BASE_PATH}/traefik/logs/`
- Docker provider watches for container labels (`traefik.enable=true`)
- File provider watches `config/dynamic/` for static route definitions
- Dashboard and API are disabled

Middleware such as BasicAuth, rate limiting, and IP allowlisting are **not** configured by default. Add them in `config/dynamic/` if needed.

## Security

- All HTTP traffic is redirected to HTTPS
- SSL certificates are automatically renewed
- Dashboard and API are disabled to reduce attack surface
- Docker socket is mounted read-only (`/var/run/docker.sock:ro`)

## Volumes

- Configuration: `config/traefik.yaml` - Main configuration file
- Dynamic Config: `config/dynamic/` - Dynamic routing configurations
- Certificates: Automatic storage of Let's Encrypt certificates

## Network

Traefik connects to the `proxynet` external network. All other services must also join `proxynet` to be discovered and routed. Create the network once before deploying any service:

```bash
docker network create proxynet
```

## DNS Provider

This setup uses CloudNS for DNS challenges, which allows:
- Wildcard certificate generation
- Certificate generation for internal services
- No need to expose services directly to the internet

## Official Traefik Image

This deployment uses the official Traefik image which provides:

- Regular security updates
- Official support from Traefik Labs
- Comprehensive documentation
- Active community support
- Enterprise features available
