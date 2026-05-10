# Gitea Mirror

Automatically mirrors GitHub repositories to your self-hosted Gitea/Forgejo instance, with a web UI and scheduled sync support.

- **Image**: `ghcr.io/raylabshq/gitea-mirror:v3.15.10`
- **Web UI**: `https://gitea-mirror.<TRAEFIK_BASE_DOMAIN>`
- **Upstream**: [RayLabsHQ/gitea-mirror](https://github.com/RayLabsHQ/gitea-mirror)

## Setup

```bash
cd docker/gitea-mirror
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

## First-Time Configuration

1. Navigate to `https://gitea-mirror.<TRAEFIK_BASE_DOMAIN>`
2. Create an account — the first user automatically becomes admin
3. Configure GitHub and Gitea credentials through the web UI
4. Set up mirror scheduling and options as desired

## Required Variables

| Variable | Description |
|---|---|
| `BETTER_AUTH_SECRET` | Session secret (min 32 chars) — generate with `openssl rand -base64 32` |
| `TRAEFIK_BASE_DOMAIN` | Base domain for Traefik routing |
| `DOCKER_BASE_PATH` | Root path for persistent data |
| `PUID` / `PGID` | User/group IDs for file ownership |

## Data Storage

Persistent data (SQLite database, config) is stored at `${DOCKER_BASE_PATH}/gitea-mirror`.

## Notes

- All GitHub and Gitea credentials can be configured via the web UI after first login
- Tokens are encrypted at rest using AES-256-GCM
- Set `SCHEDULE_ENABLED=true` and `GITEA_MIRROR_INTERVAL` in `.env` for fully automated mirroring without web UI interaction
