# Copilot Instructions for Homelab GitOps

Read `AGENTS.md` first: it holds the hard rules, repository structure, standard service pattern, exceptions table, environment variables, commit convention, CI, and the change cascade. This file adds only what `AGENTS.md` does not cover.

## Image version pinning

Check the source registry for available tags before pinning:
- Docker Hub: `https://hub.docker.com/r/vendor/image/tags`
- GitHub Container Registry: `https://github.com/owner/repo/pkgs/container/image`

Some images use `v1.2.3`, others `1.2.3`. Review release notes for version-specific changes and record the pinned version in the service's README.

## Volume mapping

- Persistent data: `${DOCKER_BASE_PATH}/service-name`
- Media services: `${MEDIA_PATH}` for content storage
- Portainer replaces the checkout on every redeploy, which leaves `./` bind mounts stale. Inject repo files with Compose `configs` instead

## Traefik dynamic configuration

Routing for backends that are not discovered through Docker labels lives in `docker/traefik/config/dynamic/`:

```yaml
# docker/traefik/config/dynamic/service-name.yaml
http:
  routers:
    service-name:
      entryPoints:
        - websecure
      rule: 'Host(`service-name.{{ env "TRAEFIK_BASE_DOMAIN" }}`)'
      service: service-name-svc
      tls:
        certResolver: cloudns
  services:
    service-name-svc:
      loadBalancer:
        servers:
          - url: 'http://internal-host:port'
```

## Debugging

- Service logs: `docker logs service-name`
- Traefik log: `${DOCKER_BASE_PATH}/traefik/logs/traefik.log`
- Service discovery: Traefik dashboard at `traefik.${TRAEFIK_BASE_DOMAIN}`
- Network membership: `docker network inspect proxynet`

## Terraform

- Two-node Docker host architecture: `sc_docker_vm` on ScaleComputing HyperCore (always-on baseline) and `dh01_docker_vm` on Proxmox `pve01`. See `docs/architecture.md`.
- Ubuntu LTS cloud images live in `terraform/modules/cloud-images/`; starter workspaces in `terraform/templates/`.
- Credentials come from environment variables via `.envrc`, never hardcoded. The `.envrc` files pull secrets from Bitwarden through direnv, so an agent cannot run `terraform plan` or `apply`: ask the user to run `direnv exec . terraform plan` in the workspace and paste the output.

## Changelog

`.github/scripts/update-changelog.py` generates `CHANGELOG.md` entries from commit messages on push to `main` (`changelog.yml`), skipping commits that touch only `CHANGELOG.md` or `.github/dependabot.yml`. Entries use date sections `## [YYYY-MM-DD]` with `### Added`, `### Changed`, `### Fixed`, `### Dependencies`, and include version numbers for image updates.

## Tooling gotchas

- Copilot CLI injects a `GH_TOKEN` without `read:org`, so `gh pr edit` fails. Run it as `env -u GH_TOKEN gh pr edit ...` to use the stored `gh` login.
