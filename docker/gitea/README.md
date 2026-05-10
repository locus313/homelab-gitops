# Gitea

Self-hosted Git service with a PostgreSQL backend. Version: **1.26.1**

## Services

| Service | Image | Description |
|---------|-------|-------------|
| `gitea` | `gitea/gitea:1.26.1` | Git service web UI and API |
| `gitea-db` | `postgres:17.5` | PostgreSQL database |

## Setup

```bash
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCKER_BASE_PATH` | Root path for service data (default: `/docker`) |
| `PUID` / `PGID` | User/group IDs for file ownership |
| `TZ` | Timezone (default: `America/Los_Angeles`) |
| `TRAEFIK_BASE_DOMAIN` | Base domain for Traefik routing |
| `GITEA_DB_NAME` | PostgreSQL database name |
| `GITEA_DB_USER` | PostgreSQL username |
| `GITEA_DB_PASSWORD` | PostgreSQL password |

## Access

- **Web UI**: `https://gitea.<TRAEFIK_BASE_DOMAIN>`
- **SSH**: `gitea.<TRAEFIK_BASE_DOMAIN>:222`

## SSH Git Clone

Gitea exposes SSH on host port `222`. To clone via SSH:

```bash
git clone ssh://git@gitea.example.com:222/user/repo.git
```

Or configure `~/.ssh/config`:

```
Host gitea.example.com
  Port 222
```

## Data Volumes

| Path | Description |
|------|-------------|
| `${DOCKER_BASE_PATH}/gitea/data` | Gitea repositories and config |
| `${DOCKER_BASE_PATH}/gitea/db` | PostgreSQL data |

## Initial Setup

On first access, the web installer will confirm your database connection settings. The admin account is created during this step.
