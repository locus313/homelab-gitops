# OpenArchiver

OpenArchiver is a secure, self-hosted platform for archiving, storing, indexing, and searching emails from Google Workspace, Microsoft 365, IMAP, PST files, and more.

## Features

- Universal email ingestion (IMAP, Google Workspace, Microsoft 365, PST, Mbox)
- Full-text search across emails and attachments (PDF, DOCX, etc.)
- File deduplication, compression, and optional AES-256 encryption at rest
- S3-compatible storage backend support (AWS S3, MinIO, etc.)
- Retention policies and legal holds
- Immutable audit trail
- Thread/conversation discovery

## Stack

| Service | Image | Purpose |
|---|---|---|
| open-archiver | `logiclabshq/open-archiver:v0.5.0` | Frontend + backend |
| postgres | `postgres:17-alpine` | Metadata database |
| valkey | `valkey/valkey:8-alpine` | Redis-compatible job queue |
| meilisearch | `getmeili/meilisearch:v1.46.1` | Full-text search engine |
| tika | `apache/tika:3.3.1.0-full` | Attachment content extraction |

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your values. Critical settings to change:
   - `TRAEFIK_BASE_DOMAIN`: Your domain (e.g., `home.example.com`)
   - `APP_URL` / `ORIGIN`: Full URL, e.g., `https://open-archiver.home.example.com`
   - `POSTGRES_PASSWORD`: Secure database password
   - `REDIS_PASSWORD`: Secure Valkey/Redis password
   - `MEILI_MASTER_KEY`: Secure Meilisearch master key
   - `JWT_SECRET`: Long, random secret string
   - `ENCRYPTION_KEY`: 32-byte hex string — generate with `openssl rand -hex 32`
   - `DATABASE_URL`: Update with matching `POSTGRES_USER` / `POSTGRES_PASSWORD`

3. Deploy:
   ```bash
   docker compose up -d
   ```

4. Access the web UI at `https://open-archiver.<TRAEFIK_BASE_DOMAIN>`

## Portainer Deployment

- Repository path: `docker/open-archiver`
- Portainer will automatically pick up changes pushed to `main`
- Set environment variables in the Portainer stack environment editor

## Storage

- Email data is stored at `${DOCKER_BASE_PATH}/open-archiver/data` on the host, mapped to `${STORAGE_LOCAL_ROOT_PATH}` inside the container
- Database, search index, and cache use named Docker volumes (`open-archiver-pgdata`, `open-archiver-meilidata`, `open-archiver-valkeydata`)
- For S3 storage, set `STORAGE_TYPE=s3` and fill in the `STORAGE_S3_*` variables

## Notes

- The `open-archiver` container is the only service exposed via Traefik; all other services (`postgres`, `valkey`, `meilisearch`, `tika`) remain on the internal `open-archiver-net` network
- The `traefik.docker.network=proxynet` label is required because the main container is on two networks
