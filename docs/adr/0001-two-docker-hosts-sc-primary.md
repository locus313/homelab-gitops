# 1. Two Docker hosts, with the ScaleComputing VM as the primary

Status: accepted

## Context

A `dh01` hardware failure took every service offline for days. ScaleComputing cannot host external hypervisors, and `dh01` runs Proxmox, so the two platforms stay separate.

## Decision

Run an always-on Docker VM (`sc_docker_vm`) on ScaleComputing as the primary host. It runs Traefik and nearly every stack. `dh01_docker_vm` on Proxmox (`pve01`) is a secondary host and currently runs only Netdata. Both VMs are provisioned by Terraform with cloud-init, and the SC VM mounts the NAS media, shared, and backups NFS exports.

## Consequences

- Losing `dh01` no longer takes down the main services.
- Rebuilding a host is a Terraform apply plus a Portainer redeploy from Git.
- The failover and data-replication design in [resilience-planning.md](../resilience-planning.md) is a plan, not a record of what is deployed. Syncthing is described there but is not part of this repo's deployment.
