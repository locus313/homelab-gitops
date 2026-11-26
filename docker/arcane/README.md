# Arcane

Arcane is a Docker management UI. This initial setup runs alongside Portainer
on dh02; it does not migrate or manage existing Portainer stacks.

The manager image is pinned to `ghcr.io/getarcaneapp/manager:v3.1.1`.
The community Terraform provider is tested against Arcane 3.0.1, so validate
compatibility with this version before migrating services.

## Bootstrap on dh02

Arcane must be running before its Terraform workspace can connect. Bootstrap it
outside both managers to avoid a dependency on either one:

1. Copy `.env.example` to `.env`. Set the domain, data path, UID and GID.
   Generate `ARCANE_ENCRYPTION_KEY` with `openssl rand -hex 32`, store it in
   Bitwarden, and keep a backup. Losing it can make encrypted data unreadable.
2. Set `ARCANE_TRUSTED_PROXIES` to Traefik's address or subnet in CIDR
   notation. Inspect `proxynet` on dh02 to find the appropriate value; trust
   only the proxy addresses needed.
3. Ensure `proxynet` exists. Create the data and project directories under
   `${DOCKER_BASE_PATH}/arcane` with restrictive permissions and ownership
   matching `PUID` and `PGID`; Arcane needs write access to both. Then run
   `docker compose up -d` from this directory on dh02.
4. Visit `https://arcane.<your-domain>`. The initial username is `arcane`.
   Retrieve the generated password from `/app/data/initial-admin-password`
   inside the container and change it at first login.
5. Create an API key and store it in Bitwarden. Continue with the
   [Terraform pilot](../../terraform/arcane/README.md).

The data and project directories are under `${DOCKER_BASE_PATH}/arcane`.
Back up both and the encryption key. Restrict their host permissions: project
environment files may contain plaintext secrets.

Arcane's `ARCANE_FILE_PERM` is set to `0600`, so newly created files are
readable and writable only by the Arcane process owner. This setting applies to
all files Arcane creates, not only `.env.global`; keep `PUID` and `PGID`
consistent with the owner of the data and project directories. Arcane preserves
the current mode when updating `.env.global`, so set the existing
`${DOCKER_BASE_PATH}/arcane/projects/.env.global` to `0600` once on dh02.

Arcane has access to the Docker socket, equivalent to administrative access
to the host. Restrict access to its UI and API. Do not enable its automatic
image updates while Watchtower manages the same containers.
