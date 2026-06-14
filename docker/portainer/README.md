# Portainer

Portainer is a lightweight container management UI that provides a web interface for managing Docker environments. This stack supports both Community Edition (CE) and Business Edition (EE/BE).

## Features

- Web-based Docker container management
- Stack deployment with GitOps support
- Image, volume, and network management
- User access control and role-based permissions
- Edge agent support for remote environment management
- **BE only:** Advanced RBAC, registry management, GitOps automation, and more

## Editions

| Edition | Image | License |
|---------|-------|---------|
| Community (CE) | `portainer/portainer-ce:2.39.3` | Free |
| Business (EE) | `portainer/portainer-ee:2.39.3` | Requires license key |

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your values:
   - `DOCKER_BASE_PATH`: Base path for Docker volumes (e.g. `/docker`)
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `TZ`: Timezone (default: `America/Los_Angeles`)
   - `PORTAINER_LICENSE_KEY`: Business Edition license key *(EE only)*

## Deployment

**Community Edition:**
```bash
docker compose up -d
```

**Business Edition:**
```bash
docker compose -f docker-compose.yml -f docker-compose.ee.yml up -d
```

**In Portainer GitOps stack config:** add `docker/portainer/docker-compose.ee.yml` as an additional compose file when using EE.

## Access

- Web interface: `https://portainer.${TRAEFIK_BASE_DOMAIN}`
- Direct fallback (initial setup): `https://<host-ip>:9443`

## Traefik Routing

Portainer uses HTTPS internally on port 9443 (self-signed certificate). Traefik routing is configured via dynamic config in `docker/traefik/config/dynamic/` rather than container labels, since the HTTPS backend requires a custom `serversTransport` configuration. See the existing `dh01.yaml` for the routing pattern.

## Volumes

- `${DOCKER_BASE_PATH}/portainer` — Portainer data, settings, and BoltDB state

A bind mount is used instead of a named Docker volume so that Syncthing can sync Portainer state between hosts as part of the homelab resilience strategy. See `docs/resilience-planning.md`.

## Initial Setup

1. On first access, create an admin user
2. Select **Docker Standalone** as the environment type
3. Connect using the Docker socket (`/var/run/docker.sock`)
4. For BE: the license key is applied automatically via the `--license-key` flag in `docker-compose.ee.yml`
