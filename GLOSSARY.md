# Glossary

Project vocabulary for managing homelab services and infrastructure.

## Language

**Stack**:
A Compose-defined application and its services.

**Project**:
An application managed by Arcane in one environment; it may be linked to a Git sync.

**Git sync**:
The link between a repository's Compose definition and an Arcane project in an environment.

**Environment**:
A Docker host managed by Arcane, either locally or through an agent.

**GitOps**:
Management of service configuration and deployments from a Git repository.

**`proxynet`**:
The shared Docker network for services routed through Traefik.

**Ingress**:
Traefik, the primary entry point for HTTP(S) traffic.

**`sc_docker_vm`**:
The always-on primary Docker VM on the ScaleComputing HyperCore cluster.

**`dh01_docker_vm`**:
The secondary Docker VM on Proxmox host `pve01`.

**`dh01`**:
The physical Intel N150 server running Proxmox (`pve01`).

**Failover**:
Planned recovery of services on `sc_docker_vm` after `dh01` is lost; it is not an implemented procedure.

**Standard service pattern**:
The usual Compose layout for a service in this repository.

**Local build stack**:
A stack using an image built on its host rather than pulled from a registry.

**Realm**:
An AzerothCore game world that players choose in the client.

**Module**:
An AzerothCore extension compiled into the worldserver.
