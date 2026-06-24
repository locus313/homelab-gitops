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
| `MAIL_ARCHIVER_IMPORT_PATH` | *(Optional)* Host path for local mbox/EML import |
| `MAIL_ARCHIVER_OAUTH_AUTHORITY` | *(Optional)* OIDC provider URL |
| `MAIL_ARCHIVER_OAUTH_CLIENT_ID` | *(Optional)* OIDC client ID |
| `MAIL_ARCHIVER_OAUTH_CLIENT_SECRET` | *(Optional)* OIDC client secret |
| `MAIL_ARCHIVER_OAUTH_DISPLAY_NAME` | *(Optional)* SSO button label (default: `SSO`) |
| `MAIL_ARCHIVER_OAUTH_ADMIN_EMAIL` | *(Optional)* Email address granted admin on SSO login |

## Access

- **Web UI**: `https://mail-archiver.<TRAEFIK_BASE_DOMAIN>`

## Data Volumes

| Path | Description |
|------|-------------|
| `${DOCKER_BASE_PATH}/mail-archiver/keys` | ASP.NET Data Protection keys |
| `${DOCKER_BASE_PATH}/mail-archiver/db` | PostgreSQL data |
| `${MAIL_ARCHIVER_IMPORT_PATH}` | *(Optional)* Host directory for local mbox/EML import |

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

## OIDC / SSO Setup

To enable OIDC SSO, uncomment the `OAuth__*` environment variables in `docker-compose.yml` and set the corresponding values in `.env`. See the [upstream OIDC guide](https://github.com/s1t5/mail-archiver/blob/main/doc/OIDC_Implementation.md) for provider-specific instructions.

## Local mbox / EML Import

To import mail from local files, uncomment the import volume and `LocalImport__AllowedPaths__0` in `docker-compose.yml`, and set `MAIL_ARCHIVER_IMPORT_PATH` in `.env` to the directory containing your files.
