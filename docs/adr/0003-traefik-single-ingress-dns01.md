# 3. Traefik as the single ingress with DNS-01 certificates

Status: accepted

## Context

Many services need HTTPS under one domain, including hosts that are not reachable from the internet.

## Decision

Traefik is the only HTTP(S) ingress, with one instance on `sc_docker_vm`. Services join the `proxynet` network and are routed by Docker labels. Certificates come from Let's Encrypt using the CloudNS DNS-01 challenge, and the cert store (`cloudns-acme.json`) lives on NAS NFS so the certificates are not tied to local disk.

## Consequences

- Services avoid host ports. Exceptions (Plex, Netdata, PXE, Storj) are listed in `AGENTS.md`.
- Backends not discovered through Docker labels use files in `docker/traefik/config/dynamic/`.
- Domains are never hardcoded; use `${TRAEFIK_BASE_DOMAIN}`.
