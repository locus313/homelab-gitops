# AzerothCore (test realm)

[AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) WotLK server with [`mod-guild-discord`](https://github.com/locus313/mod-guild-discord) compiled in, used to test the module. This is a **local build stack**: the image is built on the Docker host, never pulled.

Pinned source: AzerothCore commit `d5e818f28ee80f5a39115c3bbaa695a6f859303e` (`AC_REF`). Upstream publishes no semver tags.

## Services

| Service | Image | Description |
|---------|-------|-------------|
| `ac-database` | `mysql:8.4.6` | MySQL for auth, world, and characters |
| `ac-client-data-init` | local | One-shot client data download (maps, vmaps, mmaps, DBC) |
| `ac-db-import` | local | One-shot database create/update, including module SQL |
| `ac-authserver` | local | Login server, host port `3724` |
| `ac-worldserver` | local | World server, host port `8085` |
| `ac-discord-relay` | local | Discord bot sidecar: reads mapped Discord channels and queues messages for the module (Discord to game) |

No Traefik: the game protocol is raw TCP.

## Setup

1. Build the images on the host (20–40 minutes, needs several GB of RAM). Portainer does not rebuild them:

   ```bash
   cd docker/azerothcore
   cp .env.example .env   # edit values
   docker compose build
   ```

   Rebuild the same way whenever `AC_REF` or `MOD_GUILD_DISCORD_REF` changes. Images are tagged with `AC_REF` only, and the module clone is cached. To pick up new module commits, set `MOD_GUILD_DISCORD_REF` to the commit SHA (a branch name reuses the cached clone), then build `ac-worldserver`, `ac-db-import` and `ac-discord-relay`. Recreate containers with `docker compose up -d --no-build` and the real DB password in the environment.

2. Create the host directories owned by `PUID:PGID`:

   ```bash
   sudo mkdir -p ${DOCKER_BASE_PATH}/azerothcore/{etc,logs,data,mysql}
   sudo chown -R ${PUID}:${PGID} ${DOCKER_BASE_PATH}/azerothcore/{etc,logs,data}
   ```

3. Start the stack (first start downloads about 2 GB of client data): `docker compose up -d`, or let Portainer deploy it.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCKER_BASE_PATH` | Root path for service data (default: `/docker`) |
| `PUID` / `PGID` | User/group IDs baked into the image and used for file ownership |
| `TZ` | Timezone (default: `America/Los_Angeles`) |
| `AC_REF` | AzerothCore commit SHA to build |
| `MOD_GUILD_DISCORD_REF` | `mod-guild-discord` branch, tag, or commit to build |
| `AZEROTHCORE_DB_ROOT_PASSWORD` | MySQL root password |
| `AZEROTHCORE_DISCORD_TOKEN` | Discord bot token for `ac-discord-relay` |
| `AZEROTHCORE_DISCORD_RELAY_DB_PASSWORD` | Password of the `discord_relay` MySQL account |

## Realm address

Set the realm address to the host's LAN IP or hostname (`<REALM_ADDRESS>`) so your client can connect:

```bash
docker exec -it ac-database mysql -uroot -p acore_auth \
  -e "UPDATE realmlist SET address='<REALM_ADDRESS>' WHERE id=1;"
```

Point the client's `realmlist.wtf` at the same address.

## Test GM account

Attach to the worldserver console (detach with `Ctrl+P` `Ctrl+Q`):

```bash
docker attach ac-worldserver
```

```text
account create <name> <password>
account set gmlevel <name> 3 -1
```

## Module configuration

Enable the module in the host config, then reload from the console:

```bash
cp ${DOCKER_BASE_PATH}/azerothcore/etc/modules/mod-guild-discord.conf.dist \
   ${DOCKER_BASE_PATH}/azerothcore/etc/modules/mod-guild-discord.conf
# set GuildDiscord.Enable = 1
```

In the worldserver console: `reload config`.

Guild webhooks live in the characters database, not the config file: table `mod_discord_guild_map` (`guild_id`, `webhook_url`). Webhook URLs are secrets; never commit them.

```bash
docker exec -it ac-database mysql -uroot -p acore_characters \
  -e "INSERT INTO mod_discord_guild_map (guild_id, webhook_url) VALUES (1, '<WEBHOOK_URL>');"
```

## Discord to game relay

`ac-discord-relay` needs a Discord bot and a scoped database account.

1. In the [Discord developer portal](https://discord.com/developers/applications) create a bot, enable the **Message Content** intent, and invite it to your server with permission to read the mapped channel. Store the token in the Bitwarden item `Homelab - AzerothCore Discord Bot`.
2. Create the database account. Store its password in the Bitwarden item `Homelab - AzerothCore Relay DB`:

   ```bash
   docker exec -it ac-database mysql -uroot -p -e "
     CREATE USER 'discord_relay'@'%' IDENTIFIED BY '<password>';
     GRANT SELECT ON acore_characters.mod_discord_guild_map TO 'discord_relay'@'%';
     GRANT INSERT ON acore_characters.mod_discord_relay_queue TO 'discord_relay'@'%';"
   ```

3. Map the Discord channel to the guild (the relay reloads the map every minute):

   ```bash
   docker exec -it ac-database mysql -uroot -p acore_characters \
     -e "UPDATE mod_discord_guild_map SET discord_channel_id=<channel id> WHERE guild_id=<guild id>;"
   ```

Messages appear in game as `[Discord] Name: text`. Bot and webhook messages are ignored, and each guild is limited to 5 messages per 10 seconds.

## Notes

- Worldserver and authserver configs live in `${DOCKER_BASE_PATH}/azerothcore/etc` and are seeded from the image on first start.
- Port-forwarding is only needed if clients connect from outside the LAN.
