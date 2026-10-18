# Glossary

Project vocabulary. Use these terms in docs, issues, and commits.

| Term | Meaning |
|------|---------|
| **Stack** | One `docker/<service>/` directory, deployed as a single Portainer stack from its `docker-compose.yml`. |
| **GitOps** | Portainer polls this repo and redeploys a stack when its files change. No manual deploy. |
| **`proxynet`** | External Docker bridge network shared by every service routed through Traefik. |
| **Ingress** | Traefik, the single entry point for HTTP(S) traffic. Services that bypass it are listed in `AGENTS.md`. |
| **`sc_docker_vm`** | Always-on Docker VM on the ScaleComputing HyperCore cluster. Primary host. |
| **`dh01_docker_vm`** | Docker VM on Proxmox host `pve01` (`dh01` hardware, Intel N150). Secondary host. |
| **`dh01`** | The physical Intel N150 server that runs Proxmox (`pve01`). Its failure triggered the resilience redesign. |
| **Failover** | Planned recovery of services on `sc_docker_vm` after `dh01` is lost. See `docs/resilience-planning.md`; not an implemented procedure. |
| **Standard service pattern** | The compose template in `AGENTS.md` every stack follows. |
| **Portainer stack module** | `terraform/modules/portainer-stack`, which declares one stack, its env, and its secrets. |
| **`DOCKER_BASE_PATH`** | Root host path for persistent service data (default `/docker`). |
| **`TRAEFIK_BASE_DOMAIN`** | Base domain used in every Traefik `Host()` rule. |
| **Local build stack** | A stack whose image is built on the host with `docker compose build`, not pulled from a registry. Portainer only runs the prebuilt tag. |
| **Realm** | An AzerothCore game world that players choose in the client, registered in the `realmlist` table. |
| **Module** | An AzerothCore extension compiled into the worldserver at build time, such as `mod-guild-discord`. |
