# Arcane agent

The Arcane agent connects dh01 to the Arcane manager on dh02. The pinned
`ghcr.io/getarcaneapp/agent:v3.1.1` matches the running manager version. It
connects outbound over HTTPS and does not publish a host port.

The agent is bootstrapped manually, outside both managers, so it remains
available when the dh01 Portainer stack is removed. Its Docker socket access
grants administrative control of dh01: restrict access to the Arcane manager.

## Bootstrap

1. In Arcane, open **Agents → Add Agent**, name it `dh01`, and generate a
   single-use enrollment token. Do not paste the token into chat or commit it.
2. On dh01, change into `docker/arcane-agent` in a checkout containing this
   directory. If `.env` does not already exist, create it with restrictive
   permissions:

   ```bash
   umask 077
   cp .env.example .env
   ```

   Edit `.env` with the enrollment token, manager domain, and data path.
   Preserve an existing `.env` rather than overwriting it.

3. From this directory on dh01, start the agent:

   ```bash
   docker compose up -d
   ```

4. Confirm the agent shows **Online** in Arcane and that dh01 Netdata remains
   healthy. Do not remove the Portainer stack yet; the Netdata migration is a
   separate step after the agent and remote GitOps are verified.

The agent stores its enrolled credentials in
`${DOCKER_BASE_PATH}/arcane-agent/data`. Keep that directory persistent and
restrict access to it and `.env`. Losing the data directory requires a new
enrollment token. The token is also present in the container environment;
Docker administrators can read it.

The agent's health and connectivity should be checked in Arcane; no Traefik
router is needed for the outbound-only agent. Do not enable automatic agent
updates independently of the manager: validate and upgrade them together.
