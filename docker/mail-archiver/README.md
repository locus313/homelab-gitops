# Mail Archiver

Email archiving system with automated IMAP/M365 sync, advanced search, and export capabilities. Version: **2606.3**

## Services

| Service | Image | Description |
|---------|-------|-------------|
| `mail-archiver` | `s1t5/mailarchiver:2606.3` | Mail Archiver web UI and sync engine |
| `mail-archiver-db` | `postgres:18.4` | PostgreSQL database |

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
| `TZ` | Timezone (default: `America/Los_Angeles`) |
| `TRAEFIK_BASE_DOMAIN` | Base domain for Traefik routing |
| `MAIL_ARCHIVER_ADMIN_USER` | Initial admin username |
| `MAIL_ARCHIVER_ADMIN_PASSWORD` | Initial admin password |
| `MAIL_ARCHIVER_DB_NAME` | PostgreSQL database name |
| `MAIL_ARCHIVER_DB_USER` | PostgreSQL username |
| `MAIL_ARCHIVER_DB_PASSWORD` | PostgreSQL password |

## Access

- **Web UI**: `https://mail-archiver.<TRAEFIK_BASE_DOMAIN>`

## Data Volumes

| Path | Description |
|------|-------------|
| `${DOCKER_BASE_PATH}/mail-archiver/keys` | ASP.NET Data Protection keys |
| `${DOCKER_BASE_PATH}/mail-archiver/db` | PostgreSQL data |

## Initial Setup

On first access, log in with the credentials defined in `MAIL_ARCHIVER_ADMIN_USER` / `MAIL_ARCHIVER_ADMIN_PASSWORD`. Then navigate to **Email Accounts** to add your first IMAP or M365 account.

> **Note:** HTTPS is handled by Traefik — the application itself only serves HTTP on port 5000.

## Features

- Automated archiving from IMAP and Microsoft 365 accounts
- Advanced search with filters
- Email preview with attachments
- Export as mbox / zipped EML
- Multi-user support with per-account permissions
- Retention policies (auto-delete from mail server after configurable period)
- OIDC authentication support (see [upstream docs](https://github.com/s1t5/mail-archiver/blob/main/doc/OIDC_Implementation.md))
