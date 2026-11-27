# Homelab GitOps

> Self-hosted services managed as code — Docker Compose stacks, GitOps deployments, and Terraform-provisioned VMs for a resilient homelab.

[![YAML Lint](https://github.com/locus313/homelab-gitops/actions/workflows/yaml-lint.yml/badge.svg)](https://github.com/locus313/homelab-gitops/actions/workflows/yaml-lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A collection of Docker Compose configurations for self-hosted services, routed through Traefik with automatic TLS and managed through Arcane GitOps and Terraform-provisioned VMs on a ScaleComputing HCI cluster and a Proxmox host. Portainer is stopped and retained for rollback.

[Architecture](#architecture) • [Services](#services) • [Getting Started](#getting-started) • [Configuration](#configuration) • [Project Structure](#project-structure) • [Infrastructure](#infrastructure)

---

## Architecture

Services routed through Traefik share the `proxynet` external Docker network. Traefik is the primary HTTP(S) ingress, with documented host-network and direct-port exceptions. SSL certificates are issued automatically via Let's Encrypt with a CloudNS DNS-01 challenge.

```mermaid
graph LR
    classDef traefik fill:#e94560,stroke:#fff,color:#fff,font-weight:bold
    classDef group fill:#1565c0,stroke:#90caf9,color:#fff
    classDef hostnet fill:#4e342e,stroke:#ffcc02,color:#fff
    classDef external fill:#1b5e20,stroke:#a5d6a7,color:#eee

    CLIENT(["Browser / LAN client"]):::external
    CLOUDNS(["CloudNS<br/>DNS-01 challenge"]):::external
    TRAEFIK["Traefik<br/>:80 redirect, :443 HTTPS"]:::traefik

    subgraph PROXY["proxynet (Docker bridge)"]
        MGMT["Management<br/>Arcane, Homarr, Rackula"]:::group
        MEDIA["Media<br/>Ombi, MeTube, HandBrake"]:::group
        TOOLS["Dev tools<br/>IT-Tools, Stirling-PDF,<br/>Networking Toolbox, Code-Server"]:::group
        VCS["Version control<br/>Gitea, Gitea Mirror"]:::group
        OPS["Home and ops<br/>Home Assistant, Beszel Hub, Zerobyte,<br/>Watchtower, Mail Archiver, Storj Node"]:::group
        AI["AI and desktop<br/>Open-WebUI, Ollama, Webtop, Kasm"]:::group
    end

    HOSTNET["Host network (no Traefik)<br/>Plex, Netdata, Beszel Agent"]:::hostnet
    BOOT["PXE (raw host ports)<br/>NetbootXYZ, iVentoy"]:::hostnet

    CLIENT -->|HTTPS| TRAEFIK
    CLOUDNS -.->|certificates| TRAEFIK
    TRAEFIK --> MGMT & MEDIA & TOOLS & VCS & OPS & AI
    CLIENT -.->|direct ports| HOSTNET
    CLIENT -.->|TFTP / HTTP| BOOT
```

> **Color key:** Red = Traefik ingress · Blue = services on `proxynet` behind Traefik · Brown = services that bypass Traefik. Host placement, GitOps flow, TLS, and storage are in [docs/architecture.md](docs/architecture.md).

### Standard service pattern

Most services follow this Docker Compose structure:

```yaml
services:
  service-name:
    image: vendor/image:1.2.3      # pinned — never 'latest'
    container_name: service-name
    restart: unless-stopped
    networks:
      - proxynet
    volumes:
      - ${DOCKER_BASE_PATH}/service-name:/config
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
      TZ: ${TZ}
    labels:
      - traefik.enable=true
      - traefik.http.services.service-name.loadbalancer.server.port=8080
      - traefik.http.routers.service-name.rule=Host(`service-name.${TRAEFIK_BASE_DOMAIN}`)
      - traefik.http.routers.service-name.entrypoints=websecure
      - traefik.http.routers.service-name.tls=true
      - traefik.http.routers.service-name.tls.certresolver=cloudns

networks:
  proxynet:
    external: true
```

Notable exceptions: **Plex** and **Netdata** use `network_mode: host`; **Code-Server** shares its Tailscale sidecar's network namespace; **iVentoy** exposes raw host ports for PXE/TFTP.

---

## Services

| Category | Service | Description |
|----------|---------|-------------|
| **Ingress** | [Traefik](docker/traefik/) | Reverse proxy, TLS termination, automatic Let's Encrypt |
| **Management** | [Arcane](docker/arcane/) | GitOps management on dh02, with an [agent](docker/arcane-agent/) on dh01 |
| **Management** | [Portainer](docker/portainer/) | Stopped; configuration and data retained for rollback |
| **Dashboard** | [Homarr](docker/homarr/) | Homelab dashboard with Docker widget integration |
| **Monitoring** | [Beszel](docker/beszel/) | Lightweight server and container monitoring with agent architecture |
| **Monitoring** | [Netdata](docker/netdata/) | Real-time system and container performance metrics |
| **Backup** | [Zerobyte](docker/zerobyte/) | Restic-based backup automation with web UI and multi-protocol support |
| **Media** | [Plex](docker/plex/) | Media server with hardware transcoding (host network) |
| **Media** | [Ombi](docker/ombi/) | Media request management integrated with Plex |
| **Media** | [HandBrake](docker/handbrake/) | Video transcoder with optional GPU acceleration |
| **Media** | [MeTube](docker/metube/) | yt-dlp web interface for video downloading |
| **AI** | [Open-WebUI](docker/open-webui/) | Interface for local LLMs backed by an Ollama sidecar |
| **AI** | [Hermes Agent](docker/hermes-agent/) | AI agent with web, CLI, and Discord access |
| **Dev Tools** | [Code-Server](docker/code-server/) | Browser-based VS Code with Tailscale sidecar |
| **Dev Tools** | [IT Tools](docker/it-tools/) | 100+ developer utility tools, offline-first |
| **Dev Tools** | [Stirling PDF](docker/stirling-pdf/) | PDF manipulation toolkit |
| **Dev Tools** | [Networking Toolbox](docker/networking-toolbox/) | DNS, SSL, subnet, and network diagnostic tools |
| **Remote Desktop** | [Webtop](docker/webtop/) | Full Linux desktop in-browser with GPU acceleration |
| **Remote Desktop** | [Kasm](docker/kasm/) | Container streaming platform for disposable browser desktops |
| **VCS** | [Gitea](docker/gitea/) | Self-hosted Git service with PostgreSQL backend |
| **VCS** | [Gitea Mirror](docker/gitea-mirror/) | Automated GitHub-to-Gitea repository mirroring |
| **Home Automation** | [Home Assistant](docker/home-assistant/) | Local-first home automation with device and energy management |
| **Infrastructure** | [Rackula](docker/rackula/) | Drag-and-drop rack layout designer with PNG/PDF/SVG export |
| **Storage** | [Storj Node](docker/storj-node/) | Decentralized storage node earning STORJ tokens |
| **Network Boot** | [iVentoy](docker/iventoy/) | PXE boot server with a web UI for ISO management |
| **Network Boot** | [NetbootXYZ](docker/netbootxyz/) | Network boot menu with customizable iPXE scripts |
| **Updates** | [Watchtower](docker/watchtower/) | Automated Docker container image updates |

---

## Getting Started

### Prerequisites

- Docker 20.10+ and Docker Compose v2
- A domain name with DNS manageable via [CloudNS](https://cloudns.net) (for Let's Encrypt DNS-01)
- Git

### 1. Create the shared network

Traefik and its routed services use the `proxynet` network. Create it once before deploying them:

```bash
docker network create proxynet
```

> [!IMPORTANT]
> Services that require this network cannot start without it.

### 2. Clone and configure Traefik

Traefik **must be deployed first** — it is the routing and TLS layer every other service depends on.

```bash
git clone https://github.com/your-username/homelab-gitops.git
cd homelab-gitops/docker/traefik
cp .env.example .env
# Edit .env: set TRAEFIK_BASE_DOMAIN, CLOUDNS_SUB_AUTH_ID, CLOUDNS_AUTH_PASSWORD
docker compose up -d
```

Verify Traefik is healthy and check its logs for routing and certificate errors. The dashboard is disabled.

### 3. Deploy other services

For the managed environment, bootstrap [Arcane](docker/arcane/) and the
[dh01 agent](docker/arcane-agent/) independently, then configure Git syncs and
environment variables through [terraform/arcane](terraform/arcane/README.md).
Review the plan before enabling a sync and verify the project after applying.
Portainer's stopped containers, data, and Terraform state remain available for
rollback; see its [retirement instructions](docker/portainer/README.md).

For isolated local testing or manual bootstrap, a service can instead be started
with Compose. Do not start a second copy of an Arcane-managed project:

```bash
cd docker/<service-name>
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

---

## Configuration

### Common environment variables

Common variables used by services include:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOCKER_BASE_PATH` | Root path for all service data volumes | `/docker` |
| `PUID` | Host user ID for file ownership | `1000` |
| `PGID` | Host group ID for file ownership | `1000` |
| `TZ` | Timezone — always `America/Los_Angeles` | `America/Los_Angeles` |
| `TRAEFIK_BASE_DOMAIN` | Base domain used in Traefik routing rules | `home.example.com` |

### Service-specific variables

| Service | Key Variables |
|---------|--------------|
| Traefik | `CLOUDNS_SUB_AUTH_ID`, `CLOUDNS_AUTH_PASSWORD` |
| Plex | `PLEX_CLAIM`, `MEDIA_PATH` |
| Homarr | `SECRET_ENCRYPTION_KEY` |
| Beszel | `BESZEL_PUBLIC_KEY` |
| Netdata | `NETDATA_CLAIM_TOKEN`, `NETDATA_CLAIM_ROOMS` |
| HandBrake | `MEDIA_PATH`, `BACKUP_PATH` |
| Code-Server | `PASSWORD`, `TS_AUTHKEY` |
| Gitea | `GITEA_DB_NAME`, `GITEA_DB_USER`, `GITEA_DB_PASSWORD` |
| Gitea Mirror | `BETTER_AUTH_SECRET` |
| Hermes Agent | `HERMES_TRUSTED_PROXY`, `HERMES_DASHBOARD_BASIC_AUTH_USERNAME`, `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD`, `DISCORD_BOT_TOKEN`, `DISCORD_ALLOWED_USERS` |
| Storj Node | `WALLET`, `EMAIL`, `ADDRESS`, `STORAGE`, `STORAGE_PATH` |
| Kasm | `KASM_PORT`, `DOCKER_HUB_USERNAME`, `DOCKER_HUB_PASSWORD` |
| Rackula | `RACKULA_API_WRITE_TOKEN`, `RACKULA_AUTH_MODE`, `RACKULA_AUTH_SESSION_SECRET` |

Each service's `.env.example` file is the authoritative reference for all required and optional variables.

### Adding custom Traefik routes

For non-Docker services or advanced routing, drop a YAML file in `docker/traefik/config/dynamic/`:

```yaml
# docker/traefik/config/dynamic/my-service.yaml
http:
  routers:
    my-service:
      entryPoints: [websecure]
      rule: 'Host(`my-service.{{ env "TRAEFIK_BASE_DOMAIN" }}`)'
      service: my-service-svc
      tls:
        certResolver: cloudns
  services:
    my-service-svc:
      loadBalancer:
        servers:
          - url: 'http://192.168.1.50:8080'
```

---

## Project Structure

```
homelab-gitops/
├── docker/                     # One directory per service
│   ├── traefik/                # Reverse proxy (deploy first)
│   │   ├── config/
│   │   │   ├── traefik.yaml    # Static configuration
│   │   │   └── dynamic/        # Dynamic routing files
│   │   └── docker-compose.yml
│   └── <service>/
│       ├── docker-compose.yml
│       ├── .env.example
│       └── README.md
├── terraform/
│   ├── homelab/                # VMs: ScaleComputing + Proxmox
│   ├── arcane/                 # Arcane Git syncs and environment variables
│   ├── portainer/              # Retained Portainer configuration for rollback
│   ├── modules/
│   │   ├── cloud-images/       # Ubuntu LTS cloud image references
│   │   ├── portainer-stack/    # Portainer GitOps stack module
│   │   ├── proxmox-vm/         # Proxmox VM module
│   │   ├── vm/                 # ScaleComputing VM module
│   │   └── vm-cluster/         # Multi-VM cluster module
│   ├── templates/              # Starter workspaces
│   └── test/                   # Module test workspace
├── docs/
│   ├── architecture.md         # Diagrams: hosts, GitOps flow, TLS, storage
│   ├── resilience-planning.md  # Two-node design plan (not all deployed)
│   └── adr/                    # Architecture decision records
├── GLOSSARY.md                 # Project vocabulary
├── CODING_STANDARDS.md         # Review rules
├── .github/
│   ├── workflows/              # CI/CD pipelines
│   ├── scripts/                # Automation helpers
│   └── copilot-instructions.md # AI coding guidelines
└── CHANGELOG.md
```

---

## Infrastructure

The homelab runs across two hosts managed by Terraform:

| Host | Role | Notes |
|------|------|-------|
| ScaleComputing cluster | Always-on VM (`sc_docker_vm`) | Ubuntu 26.04 · resilient baseline |
| `pve01` (Intel N150) | Secondary VM (`dh01_docker_vm`) | Proxmox VE · iGPU for Beszel Agent |

Terraform modules live in `terraform/modules/` and cover VM creation with cloud-init, configurable CPU/memory/disk, and per-node password generation. Credentials are passed through environment variables via `.envrc` — never hardcoded.

> See [docs/architecture.md](docs/architecture.md) for host, GitOps, TLS, and storage diagrams, and [docs/resilience-planning.md](docs/resilience-planning.md) for the rationale behind the two-node architecture.

---

## Automation

### Changelog generation

Commit messages pushed to `main` are automatically harvested by `.github/scripts/update-changelog.py` and committed to `CHANGELOG.md`. The workflow skips commits that only touch `CHANGELOG.md` or `.github/dependabot.yml` to avoid loops.

### Dependabot configuration

`.github/dependabot.yml` is manually maintained. The `/docker/*` glob covers new Compose directories; add a `semver-major` ignore for each new stateful image. Docker Compose updates run daily; GitHub Actions pin updates run weekly (Saturdays).

### YAML validation

Every push or pull request touching `.yml`/`.yaml` files triggers `yamllint` via the `yaml-lint.yml` workflow. Run the same check locally before committing:

```bash
yamllint -c .github/.yamllint .
```

---

## Contributing

1. Fork the repo and create a branch, e.g. `feature/add-service`
2. Follow the [standard service pattern](#standard-service-pattern) and [new-service instructions](AGENTS.md#adding-a-new-docker-service), including the Arcane Terraform configuration
3. Always pin image versions — never use `latest`
4. Run `yamllint -c .github/.yamllint .` before committing
5. Open a PR — the checklist in the PR template walks through all required steps

See [`AGENTS.md`](AGENTS.md) for detailed conventions and [`copilot-instructions.md`](.github/copilot-instructions.md) for the full contribution guide.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Service fails to start | `proxynet` network missing | `docker network create proxynet` |
| Service not reachable via domain | Wrong or missing Traefik labels | Check labels, verify service is on `proxynet` |
| SSL certificate not issued | CloudNS credentials wrong or DNS not delegated | Check Traefik logs for ACME errors |
| File permission errors in container | Wrong `PUID`/`PGID` | Match the host user: `id $(whoami)` |
| Unexpected behaviour after update | `latest` tag pulled a breaking change | Pin images to specific version tags |

**Quick diagnostics:**

```bash
# Service logs
docker logs -f <service-name>

# Confirm service is on proxynet
docker network inspect proxynet | grep <service-name>

# Traefik access log
tail -f ${DOCKER_BASE_PATH}/traefik/logs/traefik.log
```
