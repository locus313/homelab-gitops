# Eonvelope

Self-hostable email archive with automated IMAP/POP/Exchange fetching. Version: **0.7.0**

## Services

| Service | Image | Description |
|---------|-------|-------------|
| `eonvelope` | `dacid99/eonvelope:0.7.0` | Email archive web UI and API |
| `eonvelope-db` | `mariadb:11.4` | MariaDB database |

## Setup

```bash
cp .env.example .env
# Edit .env — set all passwords, SECRET_KEY, and your domain
docker compose up -d
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCKER_BASE_PATH` | Root path for service data (default: `/docker`) |
| `TZ` | Timezone (default: `America/Los_Angeles`) |
| `TRAEFIK_BASE_DOMAIN` | Base domain for Traefik routing |
| `EONVELOPE_DB_NAME` | MariaDB database name |
| `EONVELOPE_DB_USER` | MariaDB username |
| `EONVELOPE_DB_PASSWORD` | MariaDB user password |
| `EONVELOPE_DB_ROOT_PASSWORD` | MariaDB root password |
| `EONVELOPE_SECRET_KEY` | Django secret key — generate with `openssl rand -base64 50` |
| `EONVELOPE_ADMIN_PASSWORD` | Password for the default `admin` account |

## Access

- **Web UI**: `https://eonvelope.<TRAEFIK_BASE_DOMAIN>`
- **Default admin username**: `admin`
- **Default admin password**: value of `EONVELOPE_ADMIN_PASSWORD`

> **Note:** Eonvelope only serves over HTTPS. Access via plain HTTP will show a cryptic browser error.

## Data Volumes

| Path | Description |
|------|-------------|
| `${DOCKER_BASE_PATH}/eonvelope/archive` | Archived emails and attachments |
| `${DOCKER_BASE_PATH}/eonvelope/log` | Application log files |
| `${DOCKER_BASE_PATH}/eonvelope/db` | MariaDB data |

## Initial Setup

After the container starts, log in at `https://eonvelope.<TRAEFIK_BASE_DOMAIN>` with `admin` and the value of `EONVELOPE_ADMIN_PASSWORD`. From the admin panel you can create user accounts and configure mailbox connections.

To allow users to self-register, set the `REGISTRATION_ENABLED` environment variable to `True`.
