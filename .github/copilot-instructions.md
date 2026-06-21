# Copilot Instructions for Homelab GitOps

This document provides comprehensive guidance for AI coding agents and contributors working with the Homelab GitOps repository. It ensures consistency, quality, and alignment with project standards.

## Project Overview

Homelab GitOps is a repository for managing self-hosted services using Docker Compose and GitOps principles. It includes configurations for various services, automation scripts, and workflows.

## Architecture Fundamentals

### Service Communication Pattern
All services communicate through the **`proxynet` external Docker network**. Services are NOT directly exposed to the host - instead, Traefik acts as the single ingress point:

```yaml
networks:
  proxynet:
    external: true
```

**Critical:** The `proxynet` network must be created manually before deploying any services:
```bash
docker network create proxynet
```

### Traefik-First Architecture
- **Traefik** is the cornerstone service that MUST be deployed first
- All web services use Traefik labels for automatic service discovery
- SSL certificates are automatically managed via CloudNS DNS challenge
- Services expose internal ports (not host ports) and rely on Traefik routing

### Standard Service Pattern
Every service follows this exact pattern in `docker-compose.yml`:

```yaml
services:
  service-name:
    image: vendor/image:1.2.3  # Always pin versions, never use 'latest'
    container_name: service-name
    restart: unless-stopped
    networks:
      - proxynet
    volumes:
      - ${DOCKER_BASE_PATH}/service-name:/config
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
      TZ: ${TZ}  # Always America/Los_Angeles
    labels:
      - traefik.enable=true
      - traefik.http.services.service-name.loadbalancer.server.port=INTERNAL_PORT
      - traefik.http.routers.service-name.rule=Host(`service-name.${TRAEFIK_BASE_DOMAIN}`)
      - traefik.http.routers.service-name.entrypoints=websecure
      - traefik.http.routers.service-name.tls=true
      - traefik.http.routers.service-name.tls.certresolver=cloudns

networks:
  proxynet:
    external: true
```

**Pattern Exceptions:**
- **Plex**: Uses `network_mode: host` instead of proxynet (requires direct network access for discovery)
- **Netdata**: Uses `network_mode: host` for direct system-level monitoring; accessible at `:19999` only (not via Traefik)
- **Beszel Agent**: The agent sidecar uses `network_mode: host` + `/dev/dri` + `docker.sock` for full system monitoring; the hub runs normally on proxynet
- **Code-Server**: Uses `network_mode: service:code-server-ts` — shares the Tailscale sidecar's network namespace instead of proxynet
- **GPU Services** (Webtop, HandBrake, Kasm, Ollama): Mount `/dev/dri:/dev/dri` for hardware acceleration
- **Docker Integration** (Homarr, Webtop, Portainer, Traefik, Netdata, Watchtower, Code-Server): Mount `/var/run/docker.sock` for container management or monitoring
- **Multi-Service Stacks**:
  - **Gitea**: `gitea` + `postgres:18` sidecar; exposes SSH on `222:22` for Git over SSH
  - **Open-Archiver**: `open-archiver` + `postgres:17` + `valkey` (Redis-compatible) + `meilisearch` + `tika`; all sidecars on an isolated internal `open-archiver-net`
  - **Open-WebUI**: `open-webui` + `ollama` sidecar; ollama mounts `/dev/dri` for GPU inference
- **Kasm**: Privileged mode, `/dev/dri` GPU, exposes `${KASM_SETUP_PORT:-3000}:3000` (setup wizard) and `${KASM_PORT}:${KASM_PORT}` (runtime, configurable); also joined to default network
- **Home Assistant**: Uses `proxynet` + `privileged: true` (NOT host network); mounts `/run/dbus` for device/Bluetooth access
- **iVentoy**: Privileged mode + direct host ports (`26000`, `16000`, `10809`, `69/udp`) for PXE/TFTP boot services; does NOT use Traefik routing
- **NetbootXYZ**: Exposes `69:69/udp` for TFTP and `8080:80` for asset serving alongside Traefik routing
- **Storj Node**: Requires host port-forwarding for `28967` (TCP + UDP) for peer-to-peer connectivity
- **Portainer**: Exposes `9443:9443` directly as a fallback for initial setup alongside Traefik dynamic config routing (uses HTTPS backend on 9443)

**Image Version Pinning:**
- **ALWAYS pin to specific versions** - never use `latest` tag
- **Check the source registry** for available tags before pinning:
  - Docker Hub: `https://hub.docker.com/r/vendor/image/tags`
  - GitHub Container Registry: `https://github.com/owner/repo/pkgs/container/image`
- **Verify tag format**: Some images use `v1.2.3`, others use `1.2.3` (without `v` prefix)
- **Check release notes**: Review GitHub releases or registry documentation for version-specific changes
- **Update README.md**: Document the pinned version in the service's README

## Key Components

### Services
- **Traefik**: Reverse proxy and SSL termination (DEPLOY FIRST)
- **Portainer**: Container management UI with GitOps stack deployment (CE and EE editions)
- **Homarr**: Homelab dashboard with Docker integration
- **Beszel**: Lightweight server monitoring with agent architecture
- **Netdata**: Real-time system and container performance monitoring
- **Plex**: Media server with hardware transcoding support
- **Ombi**: Media request management integrated with Plex
- **Webtop**: Full Linux desktop environment in browser with GPU acceleration
- **Kasm**: Container streaming platform for disposable browser-based desktops and apps (DaaS/RBI)
- **Code-Server**: Browser-based VSCode with Tailscale integration
- **HandBrake**: Video transcoder with GPU acceleration
- **MeTube**: yt-dlp web interface for video downloading
- **Stirling PDF**: PDF manipulation toolkit
- **IT Tools**: Developer utilities collection
- **Networking Toolbox**: 100+ offline-first networking, DNS, SSL, and security tools
- **iVentoy/NetbootXYZ**: Network boot services
- **Gitea**: Self-hosted Git service with PostgreSQL backend
- **Gitea-Mirror**: Automated GitHub-to-Gitea repository mirroring with web UI
- **Home Assistant**: Local-first home automation platform with device and energy management
- **Open-Archiver**: Email archiving and search platform (IMAP, Google Workspace, M365, PST)
- **Rackula**: Drag-and-drop rack layout designer with PNG/PDF/SVG export
- **Zerobyte**: Restic-based backup automation with web UI and multi-protocol support
- **Storj Node**: Decentralized storage node that earns STORJ tokens for sharing disk/bandwidth
- **Watchtower**: Automated container updates
- **Open-WebUI**: AI interface for local LLMs

## Developer Workflows

### Environment Configuration Pattern
Every service directory contains:
- `docker-compose.yml` - Service definition
- `.env.example` - Template with ALL required variables (26 services have this)
- `README.md` - Service-specific documentation with setup instructions

**Workflow:**
```bash
cd docker/service-name
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

**Critical**: All services reference environment variables in their compose files - NEVER hardcode values. The `.env.example` files document all required and optional variables with descriptive placeholder values.

**Common Environment Variables Pattern:**
- `DOCKER_BASE_PATH` - Root path for all service data (default: `/docker`)
- `PUID`/`PGID` - User/group IDs for file ownership (check with `id` command)
- `TZ` - **Always** set to `America/Los_Angeles` for consistency
- `TRAEFIK_BASE_DOMAIN` - Base domain for service routing (e.g., `example.com`)
- Service-specific variables use SCREAMING_SNAKE_CASE with service prefix

### Deployment Patterns

1. **Portainer GitOps (Recommended)**:
   - Repository URL: Your fork URL
   - Compose path: `docker/service-name`
   - Portainer automatically pulls changes and redeploys

2. **Manual Deployment**:
   ```bash
   cd docker/service-name
   docker compose up -d
   ```

### Traefik Dynamic Configuration
Place service-specific routing in `docker/traefik/config/dynamic/`:

```yaml
# docker/traefik/config/dynamic/service-name.yaml
http:
  routers:
    service-name:
      entryPoints:
        - websecure
      rule: 'Host(`service-name.{{ env "TRAEFIK_BASE_DOMAIN" }}`)'
      service: service-name-svc
      tls:
        certResolver: cloudns
  services:
    service-name-svc:
      loadBalancer:
        servers:
          - url: 'http://internal-host:port'
```

### Testing & Validation

**YAML Linting**: All YAML files are validated using `.github/.yamllint` configuration:
```bash
yamllint -c .github/.yamllint .
```

**GitHub Actions**: `yaml-lint.yml` workflow runs on every push affecting YAML files.

### Debugging Workflows

**Service Logs:**
```bash
docker logs service-name
```

**Traefik Issues:**
- Check `${DOCKER_BASE_PATH}/traefik/logs/traefik.log`
- Verify service discovery in Traefik dashboard: `traefik.${TRAEFIK_BASE_DOMAIN}`
- Confirm service is in `proxynet` network: `docker network inspect proxynet`

## Critical Conventions

### Environment Variables
- **ALWAYS** use `.env` files, never hardcode values
- **Common variables**: `DOCKER_BASE_PATH`, `PUID`, `PGID`, `TZ`, `TRAEFIK_BASE_DOMAIN`
- **Timezone Standard**: Always use `TZ=America/Los_Angeles` for consistency across all services
- **Sensitive data**: Use descriptive placeholder names (e.g., `your_secure_password_here`)

### Volume Mapping Standards
- Use `${DOCKER_BASE_PATH}/service-name` for persistent data
- Media services use `${MEDIA_PATH}` for content storage
- Always use relative paths for Portainer compatibility

### Security Patterns
- Services with authentication: Use environment variables for credentials
- GPU acceleration: Mount `/dev/dri:/dev/dri` for Intel/AMD GPUs
- Container permissions: Always set `PUID`/`PGID` for file ownership

## Integration Points

### Terraform Infrastructure
- **Dual provider setup**: ScaleComputing HyperCore (`ScaleComputing/hypercore`) + Proxmox (`bpg/proxmox`) for a two-node Docker host architecture
  - `sc_docker_vm` — always-on VM on the ScaleComputing cluster (resilient baseline)
  - `dh01_docker_vm` — VM on `pve01` (Proxmox on an Intel N150 mini PC)
- **Cloud images**: Ubuntu LTS (26.04 Resolute) in `terraform/modules/cloud-images/`
- **VM templates**: Standardized configurations in `terraform/templates/`
- **Auth**: All credentials passed via environment variables (`.envrc`); never hardcoded
- See `docs/resilience-planning.md` for the full two-node architecture rationale

### GitHub Automation

**Changelog Auto-Generation:**
- Script: `.github/scripts/update-changelog.py` generates entries from commit messages
- Trigger: Runs on push to `main` branch (via `changelog.yml` workflow), skipping commits that only touch `CHANGELOG.md` or `.github/dependabot.yml`
- Output: Auto-commits updated `CHANGELOG.md` directly to `main`
- Concurrency: Non-cancellable — rapid pushes queue up so each entry is recorded

**Dependabot Auto-Configuration:**
- Script: `.github/scripts/generate-dependabot.sh` auto-discovers all compose files
- Trigger: Runs on push to `main` branch (via `update-dependabot.yml` workflow)
- Output: Creates PR with updated `.github/dependabot.yml` if changes detected
- Pattern matching: Finds `docker-compose.yml`, `compose.yml`, and variants
- Schedule: Docker compose updates daily, GitHub Actions weekly (Saturdays)
- **Critical**: Script uses regex `'.*/\(docker-\)?compose\(-[\w]+\)?\(?>\.[\w-]+\)?\.ya?ml'` to find compose files

**YAML Validation:**
- Workflow: `yaml-lint.yml` runs `yamllint` on all YAML files
- Configuration: `.github/.yamllint` (extends default, disables `document-start` rule)
- Trigger: Every push/PR affecting `*.yml` or `*.yaml` files
- **Usage**: Run locally with `yamllint -c .github/.yamllint .` before committing

### External Dependencies
- **CloudNS**: DNS provider for SSL certificate automation
- **Docker Hub/GHCR**: Container image sources
- **Let's Encrypt**: SSL certificate authority

## Contribution Guidelines

1. **Follow the service pattern**: Use existing services as templates
2. **Test locally**: Verify service starts and Traefik routing works
3. **Update CHANGELOG.md**: Document all changes following the established format:
   - Use date-based sections: `## [YYYY-MM-DD]`
   - Categorize changes: `### Added`, `### Changed`, `### Fixed`, `### Dependencies`
   - Include specific version numbers for image updates
   - Document configuration changes and new features comprehensively
   - Reference service names and file paths clearly
4. **Validate YAML**: Ensure all files pass linting
5. **Environment examples**: Always provide complete `.env.example` files

## Maintenance Matrix

When you change a file, **also update** these downstream files:

| Changed file | Must also update |
|---|---|
| `docker/<svc>/docker-compose.yml` (add/remove env var) | `docker/<svc>/.env.example` |
| `docker/<svc>/docker-compose.yml` (change internal port) | Traefik `loadbalancer.server.port` label in same file |
| `docker/<svc>/docker-compose.yml` (rename service/container) | Volume paths, Traefik labels, `docker/<svc>/README.md` access URL |
| `docker/<svc>/.env.example` (add/rename variable) | `docker/<svc>/docker-compose.yml`, `docker/<svc>/README.md` |
| `terraform/modules/<module>/` (change variable interface) | `terraform/homelab/`, `terraform/portainer/`, `terraform/test/` callers |
| `.github/scripts/generate-dependabot.sh` | Run locally to verify `.github/dependabot.yml` output is correct |
| `.github/workflows/yaml-lint.yml` (change Python version) | `.github/workflows/copilot-setup-steps.yml` (keep versions in sync) |
| Any new `docker/<svc>/docker-compose.yml` added | Push to `main` so `update-dependabot.yml` picks it up and updates Dependabot |

## Common Pitfalls

- **Missing proxynet network**: Services will fail to start
- **Incorrect Traefik labels**: Service won't be accessible via domain
- **Hardcoded paths**: Use environment variables for all paths
- **Missing GPU setup**: Hardware acceleration services need device mounting
- **Port conflicts**: Use Traefik routing instead of host port mapping
