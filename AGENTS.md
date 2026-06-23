# AGENTS.md

## Project Overview

`homelab-gitops` manages self-hosted services as code — Docker Compose stacks deployed via Portainer GitOps, and VMs provisioned by Terraform on a ScaleComputing HyperCore cluster and a Proxmox host.

**Hard rules:**
- Never use `latest` image tag — always pin to a specific semver tag
- Never hardcode paths — always use `${DOCKER_BASE_PATH}`
- Never hardcode domains — always use `${TRAEFIK_BASE_DOMAIN}`
- All service traffic routes through Traefik (exceptions documented below)
- `TZ` is always `America/Los_Angeles`

## Repository Structure

```
homelab-gitops/
├── docker/                  # Docker Compose service stacks
│   └── <service-name>/
│       ├── docker-compose.yml
│       ├── .env.example     # ALL required variables with placeholder values
│       └── README.md        # Setup instructions, access URL, notes
├── terraform/               # Infrastructure as Code
│   ├── homelab/             # ScaleComputing HyperCore VM workspace
│   ├── portainer/           # Portainer stack deployment via API
│   ├── modules/             # Reusable Terraform modules
│   │   ├── cloud-images/    # Ubuntu LTS cloud image management
│   │   ├── proxmox-vm/      # Proxmox VM module
│   │   ├── vm/              # ScaleComputing VM module
│   │   └── vm-cluster/      # Multi-VM cluster module
│   └── templates/           # New workspace starter templates
├── .github/
│   ├── workflows/           # yaml-lint, changelog, update-dependabot
│   ├── scripts/             # update-changelog.py, generate-dependabot.sh
│   ├── copilot-instructions.md
│   ├── skills/              # Copilot Agent Skills (~34 skills)
│   ├── agents/              # Copilot Agent definitions
│   ├── chatmodes/           # Copilot Chat modes
│   └── instructions/        # Copilot instruction files (applyTo patterns)
├── CHANGELOG.md             # Auto-updated by changelog.yml on every push to main
└── README.md
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Container orchestration | Docker Compose, Portainer GitOps |
| Reverse proxy / TLS | Traefik + Let's Encrypt (CloudNS DNS-01 challenge) |
| Container network | `proxynet` external Docker bridge network |
| Infrastructure (IaC) | Terraform — `ScaleComputing/hypercore` + `bpg/proxmox` providers |
| Automation scripts | Python 3, Bash |
| YAML validation | `yamllint` (config: `.github/.yamllint`) |
| Commit convention | Conventional Commits (enforced via commit hook) |

## Build & Run

**One-time prerequisite — create the shared network:**
```bash
docker network create proxynet
```

**Deploy a service:**
```bash
cd docker/<service-name>
cp .env.example .env
# Edit .env — fill in all placeholder values
docker compose up -d
```

**Validate YAML locally (matches CI):**
```bash
yamllint -c .github/.yamllint .
```

**Terraform workspace:**
```bash
cd terraform/homelab        # or terraform/portainer
cp .envrc.example .envrc    # fill in credentials
source .envrc
terraform init
terraform plan
terraform apply
```

## Testing

This is a configuration repo — validation replaces unit tests.

| Check | Command |
|-------|---------|
| YAML lint (all files) | `yamllint -c .github/.yamllint .` |
| Validate a compose file | `docker compose -f docker/<service>/docker-compose.yml config` |
| Validate Terraform | `cd terraform/<workspace> && terraform validate` |
| Preview infrastructure | `cd terraform/<workspace> && terraform plan` |

CI runs `yamllint` automatically on every push that touches `.yml`/`.yaml` files.

## Key Patterns and Conventions

### Standard Docker Service Pattern

Every service follows this template in `docker-compose.yml`:

```yaml
services:
  service-name:
    image: vendor/image:1.2.3       # Always pin — never 'latest'
    container_name: service-name    # Matches directory name
    restart: unless-stopped
    networks:
      - proxynet
    volumes:
      - ${DOCKER_BASE_PATH}/service-name:/config
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
      TZ: ${TZ}                     # Always America/Los_Angeles
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

### Exceptions to the Standard Pattern

| Service | Exception |
|---------|-----------|
| `plex` | `network_mode: host` — requires direct network for discovery |
| `netdata` | `network_mode: host` — direct system monitoring; no Traefik |
| `beszel` agent | `network_mode: host` + `/dev/dri` + `docker.sock` |
| `code-server` | `network_mode: service:code-server-ts` (Tailscale sidecar namespace) |
| `kasm` | Privileged, `/dev/dri`, host ports `3000` (setup) + `${KASM_PORT}` (runtime) |
| `iventoy` | Privileged, direct host ports (`26000`, `16000`, `10809`, `69/udp`), no Traefik |
| `home-assistant` | `proxynet` + `privileged: true` + `/run/dbus` |
| `gitea` | Adds `postgres:18` sidecar; SSH on `222:22` |
| `storj-node` | Requires host port-forward `28967` (TCP + UDP) |
| `portainer` | Also exposes `9443:9443` directly as a fallback |

### Common Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DOCKER_BASE_PATH` | Root path for all service data | `/docker` |
| `PUID` / `PGID` | File ownership (run `id` to find yours) | — |
| `TZ` | Timezone — always this value | `America/Los_Angeles` |
| `TRAEFIK_BASE_DOMAIN` | Base domain for all service URLs | e.g. `example.com` |

### Commit Convention

```
<type>(<scope>): <description>
```

Types: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`  
Scopes use the directory path: `docker/traefik`, `terraform/homelab`, `.github/workflows`  
Breaking changes: `feat!: drop TLS 1.0 support`

## CI/CD

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `yaml-lint.yml` | push (`*.yml`, `*.yaml`) | Runs `yamllint` on all YAML files |
| `changelog.yml` | push to `main` | Auto-appends entries to `CHANGELOG.md` and commits |
| `update-dependabot.yml` | push to `main` | Discovers all compose files, updates `.github/dependabot.yml` via PR |

**Portainer GitOps:** Each `docker/<service>` directory is a Portainer stack. Portainer polls the repo and redeploys automatically on commit.

**Dependabot:** Auto-configured by `.github/scripts/generate-dependabot.sh`. Docker image updates run daily; GitHub Actions updates run weekly (Saturdays).

## Adding a New Docker Service

All 3 files must be created together — they are always in sync:

1. **`docker/<service-name>/docker-compose.yml`** — use the standard pattern above
2. **`docker/<service-name>/.env.example`** — list every `${VAR}` referenced in the compose file with a descriptive placeholder value
3. **`docker/<service-name>/README.md`** — document: purpose, access URL (`https://<service>.<domain>`), prerequisites, notes

**Image version:** Check the registry for the latest stable tag before committing.  
**YAML check:** Run `yamllint -c .github/.yamllint docker/<service-name>/docker-compose.yml` before committing.  
**Commit message:** `feat(docker/<service-name>): add initial <Service Name> stack`

### Change Cascade

| When you change... | Also update... |
|--------------------|----------------|
| `docker-compose.yml` environment vars | `.env.example` (add/remove vars) |
| Service internal port | Traefik `loadbalancer.server.port` label |
| Service name / container_name | Volume paths, Traefik labels, README access URL |
| Terraform module interface | All workspaces that call the module (`homelab/`, `portainer/`, `test/`) |
| `.github/scripts/generate-dependabot.sh` | Run locally to verify `.github/dependabot.yml` output |

## Common Pitfalls

- **`proxynet` network missing** — `docker network create proxynet` must run before first deploy
- **`latest` image tag** — always pin; Dependabot can't track `latest`
- **Missing `.env.example`** — Portainer GitOps users need this to configure the stack
- **Hardcoded domain in Traefik label** — must be `` Host(`<name>.${TRAEFIK_BASE_DOMAIN}`) ``
- **Wrong `TZ`** — must be `America/Los_Angeles`
- **GPU services without `/dev/dri`** — HandBrake, Webtop, Kasm, Ollama all need device mount
- **Port conflicts** — use Traefik routing; only add host ports for services that genuinely need them (PXE, P2P, etc.)
