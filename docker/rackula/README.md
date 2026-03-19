# Rackula

[Rackula](https://github.com/RackulaLives/Rackula) is an open-source drag-and-drop rack layout designer for homelabs and data centers. Plan your rack layouts, visualize real device images, and export diagrams to PNG, PDF, or SVG.

## Features

- Drag-and-drop devices into rack units
- Real device images from the NetBox devicetype-library
- Export layouts to PNG, PDF, and SVG
- QR code sharing (layout lives in a URL)
- Persistent storage via the API sidecar
- Optional authentication (local or OIDC)

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your values:
   - `TRAEFIK_BASE_DOMAIN`: Your base domain for Traefik routing
   - `DOCKER_BASE_PATH`: Root path for Docker volumes
   - `RACKULA_API_WRITE_TOKEN`: Bearer token protecting write API routes (strongly recommended)
   - `RACKULA_AUTH_MODE`: Set to `local` or `oidc` to enable authentication
   - `RACKULA_AUTH_SESSION_SECRET`: Required when auth is enabled (min. 32 characters)

3. Create the data directory with the correct ownership (uid 1001 is the container user):
   ```bash
   mkdir -p /docker/rackula/data
   sudo chown 1001:1001 /docker/rackula/data
   ```

4. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Architecture

This deployment uses two containers:

- **rackula**: Nginx-based frontend (served via Traefik)
- **rackula-api**: Node.js API sidecar for persistent layout storage

The frontend proxies API requests internally to `rackula-api` over the `proxynet` Docker network. Only the frontend is exposed via Traefik.

## Access

- Web Interface: `https://rackula.yourdomain.com`

## Security Notes

- `RACKULA_API_WRITE_TOKEN` limits which clients can save/delete layouts — always set this in production.
- `RACKULA_AUTH_SESSION_COOKIE_SECURE` defaults to `true` since Traefik handles HTTPS — do not set to `false` in production.
- Generate strong secrets with `openssl rand -hex 32`.
