# Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) provides an AI agent
through a web dashboard, CLI, and Discord gateway.

- **Image**: `nousresearch/hermes-agent:v0.23.3`
- **Web UI**: `https://hermes-agent.<TRAEFIK_BASE_DOMAIN>`

## Setup

1. Create a Discord bot, enable its Message Content Intent, invite it to the
   server, and obtain its token and your Discord user ID. See the upstream
   [Discord setup guide](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord).
2. On the Docker host, find Traefik's current address on `proxynet`:

   ```bash
   docker inspect -f '{{with index .NetworkSettings.Networks "proxynet"}}{{.IPAddress}}{{end}}' traefik
   ```

3. Set that single IP as `HERMES_TRUSTED_PROXY`. Hermes needs it to trust
   Traefik's HTTPS forwarding headers and set secure login cookies. Do not use
   a whole network: other containers on it could spoof forwarded headers.
4. For a standalone deployment, copy `.env.example` to `.env`, fill in all
   values, and run `docker compose up -d`. For Portainer, configure the
   corresponding `terraform/portainer` variables and secrets before applying.
5. Sign in at the web UI with the dashboard username and password. Configure
   a model provider and credentials through the dashboard or `hermes setup`
   before chatting.

The Traefik address can change when its container is recreated. If it changes,
update `HERMES_TRUSTED_PROXY` and redeploy Hermes before using the dashboard;
otherwise its login cookies may not be marked secure. The dashboard authenticates
direct access from other `proxynet` containers too; do not publish its port.

## CLI

On the Docker host, start an interactive session or setup:

```bash
docker exec -it hermes-agent hermes
docker exec -it hermes-agent hermes setup
```

The container persists configuration, credentials, sessions, and agent data in
`${DOCKER_BASE_PATH}/hermes-agent`. Protect and back up this directory. The
dashboard password and Discord token are also present in container environment
variables and Portainer/Terraform state; restrict access to those systems.

Hermes can run commands inside its container. This stack does not mount the
Docker socket or host workspaces; review agent tools, permissions, and
[security guidance](https://hermes-agent.nousresearch.com/docs/user-guide/security)
before granting additional access.
