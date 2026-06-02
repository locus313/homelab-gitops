# Changelog

All notable changes to this project will be documented in this file.

## [2026-06-02]

### Dependencies
- Bump the terraform-providers group across 2 directories with 2 updates (#353).
- Bump rackulalives/rackula in /docker/rackula (#352).
- Bump rackulalives/rackula-api in /docker/rackula (#351).

## [2026-05-31]

### Added
- Add initial Eonvelope configuration files including .env.example, README.md, and docker-compose.yml.
- Add Eonvelope stack configuration and related variables.
- Add weekly cron job to prune unused Docker images.
- Enhance .envrc.example files with Bitwarden integration for secrets management.
- Refactor Bitwarden helper functions in .envrc.example files for improved clarity.
- Refactor Bitwarden helper functions in .envrc.example files for improved performance and clarity.

## [2026-05-29]

### Dependencies
- Bump the docker-images group across 2 directories with 4 updates (#348).

## [2026-05-27]

### Dependencies
- Bump the docker-images group across 2 directories with 3 updates (#347).

## [2026-05-26]

### Dependencies
- Bump the docker-images group across 2 directories with 2 updates (#346).

## [2026-05-25]

### Dependencies
- Bump the docker-images group across 4 directories with 4 updates (#345).
- Bump bpg/proxmox (#344).

## [2026-05-23]

### Dependencies
- Bumped `actions/checkout` from 4 to 6.

### Added
- Add Netdata monitoring stack for dh01 and dh02 with configuration variables.

## [2026-05-22]

### Changed
- Remove dh01 autoinstall configuration files and scripts.

### Fixed
- Update Proxmox answer file template and setup script for kebab-case consistency.
- Remove unnecessary video parameters from Proxmox kernel boot command.
- Add missing video parameters to Proxmox kernel boot command.

### Added
- Add Proxmox ISO copying to setup script and update boot configuration.
- Add Proxmox VM module for dh01 Docker host setup with cloud-init support.

### Dependencies
- Bump the docker-images group across 3 directories with 4 updates (#342).

## [2026-05-21]

### Added
- Add dh01 autoinstall assets and scripts for Ubuntu 26.04.
- Enhance ISO discovery logic to support optional point releases.
- Add per-host iPXE script for Ubuntu 26.04 autoinstall on dh01.
- Add Proxmox VE unattended installation support with answer file and scripts.

### Fixed
- Correct PASSWORD_HASH default value in .envrc.example.
- Update user-data script to clarify .envrc location and improve error messages.
- Update iPXE kernel parameters to use fixed ISO name for Ubuntu 26.04 autoinstall.
- Refactor iPXE kernel parameters to use variable for seed URL.
- Add interactive-sections to Ubuntu autoinstall template.
- Add early-commands to handle WAITING state in Ubuntu autoinstall.

## [2026-05-20]

### Dependencies
- Bump the docker-images group across 2 directories with 2 updates (#339).

## [2026-05-19]

### Added
- `changelog` — Add workflow to automatically update CHANGELOG.md on push.
- `code-server` — Added `bootstrap.sh` to `custom-cont-init.d/`; on container start it fetches and executes `install-additional-tools.sh` directly from GitHub, so only the bootstrap file needs to be present on the host.

### Fixed
- `docker/code-server/docker-compose.yml` — updated `custom-cont-init.d` volume bind-mount path to use `${DOCKER_BASE_PATH}/code-server/custom-cont-init.d`.
- `docker/code-server/custom-cont-init.d/install-additional-tools.sh` — improved Docker group configuration to look up GID from the socket at runtime and only create the group if one does not already exist; hardened Packer installation to skip adding the HashiCorp apt repo when it is already present (avoids conflicting `Signed-By` values from the `code-server-terraform` mod).

### Dependencies
- Bump the docker-images group across 3 directories with 3 updates (#338).

## [2026-05-18]

### Fixed
- `docker/code-server/custom-cont-init.d/install-additional-tools.sh` — multiple improvements to Homebrew installation: script now runs `brew` as the `abc` user (via `su -c`), correctly handles package installation, and streamlines the overall install flow.

### Dependencies
- Bumped `gitea/gitea` to 1.26.1 in `/docker/gitea`.
- Bumped `linuxserver/homeassistant` from 2026.5.1 to 2026.5.2.
- Bumped Terraform `hashicorp/random` from 3.8.1 to 3.9.0 in `terraform/test`.
- Bumped Terraform `vultr/vultr` from 2.31.1 to 2.31.2 in `terraform/test`.

## [2026-05-17]

### Added
- `terraform/portainer/` — initial Terraform configuration for managing a Portainer instance via the Portainer provider.
- `docker/portainer/` — initial Docker Compose stack and Traefik dynamic configuration for Portainer CE.
- `docker/portainer/config/dynamic/portainer.yaml` — Traefik dynamic router for the Portainer service.
- `docker/code-server/` — added `.env.example` with all required environment variables for the Code-Server stack.
- Terraform `homelab` module: added `nfs_backup_export` variable and updated cloud-init user-data template.
- Terraform `homelab` module: added initial ScaleComputing / HyperCore VM provisioning configurations and templates.

### Changed
- Updated `README.md` to reflect current repository state: corrected Traefik version to `v3.7.1`, added Gitea, Gitea Mirror, Kasm, and Rackula to the Technology Stack, architecture diagram, env vars table, and project structure.

### Fixed
- `docker/gitea/docker-compose.yml` — corrected PostgreSQL data volume path, simplified healthcheck command, and added missing `start_period` to healthcheck configuration.
- `docker/traefik/` — removed deprecated `LEGO_CA_SERVER` variable and updated DNS propagation timeout env var name.
- `docker/plex/docker-compose.yml` — removed unnecessary `/dev/dri` device mapping; bumped image to `1.43.1.10611-1e34174b1` (manual update, Dependabot cannot handle Plex's non-standard versioning).
- `docker/handbrake/docker-compose.yml` — removed unnecessary `/dev/dri` device mapping (GPU passthrough already handled by image).
- `docker/metube/docker-compose.yml` — standardized `PUID`/`PGID` environment variable names and added missing state volume and env vars.
- `docker/ombi/docker-compose.yml` — added missing resource limits configuration.
- `docker/netbootxyz/docker-compose.yml` — clarified comments around custom menu file bind-mount management.
- `docker/portainer/docker-compose.yml` — updated MeTube output template reference and added `DOCKER_BASE_PATH` environment variable.

### Dependencies
- Bumped `postgres` from 18.3 to 18.4 in `/docker/gitea`.
- Bumped `ollama/ollama` from 0.23.4 to 0.24.0.
- Bumped `rackulalives/rackula` from v0.9.4-persist to v0.9.5-persist.
- Bumped `rackulalives/rackula-api` from 0.9.4 to 0.9.5.

## [2026-05-16]

### Added
- Terraform `modules/cloud-images/`: added Ubuntu 26.04 LTS (Resolute Raccoon) cloud image support.

## [2026-05-14]

### Dependencies
- Bumped `traefik` from v3.7.0 to v3.7.1.
- Bumped `ollama/ollama` from 0.23.3 to 0.23.4.

## [2026-05-13]

### Dependencies
- Bumped `ollama/ollama` from 0.23.2 to 0.23.3.
- Bumped `nickfedor/watchtower` from 1.16.1 to 1.17.0.

## [2026-05-11]

### Dependencies
- Bumped `homarr-labs/homarr` from v1.60.0 to v1.61.0.
- Bumped `linuxserver/homeassistant` from 2026.5.0 to 2026.5.1.
- Bumped `open-webui/open-webui` from v0.9.2 to v0.9.5.
- Bumped `postgres` from 17.5 to 18.3 in `/docker/gitea` (major version upgrade).
- Bumped Terraform `vultr/vultr` provider from 2.31.0 to 2.31.1.

## [2026-05-10]

### Fixed
- `docker/traefik/config/traefik.yaml` — reverted log level from `DEBUG` back to `INFO` for production stability (temporary debug session on this date).

## [2026-05-09]

### Added
- `docker/gitea/` — initial Docker Compose stack for self-hosted Gitea with a PostgreSQL sidecar, Traefik routing, and SSH passthrough on port 222.
- `docker/gitea-mirror/` — initial Docker Compose stack for Gitea Mirror (automated repository mirroring UI using better-auth).
- `docker/traefik/.env.example` — added `LEGO_PROPAGATION_TIMEOUT` variable for configuring DNS-01 challenge record propagation wait time.

### Fixed
- `docker/traefik/config/traefik.yaml` — added `delayBeforeCheck` (90 s) to `dnsChallenge` to improve reliability of DNS-01 certificate issuance on slow resolvers.
- `docker/traefik/` — defaulted `LEGO_PROPAGATION_TIMEOUT` to 600 seconds in `.env.example`.

## [2026-05-08]

### Changed
- `docker/netbootxyz/` — removed the `99-chown-custom-menu` ownership-fix init script; updated README to explain the revised TFTP permissions approach (files are now created with correct ownership rather than fixed at startup).

### Dependencies
- Bumped `stirling-tools/stirling-pdf` from 2.10.0 to 2.10.1.
- Bumped `ollama/ollama` from 0.23.1 to 0.23.2.

## [2026-05-07]

### Dependencies
- Bumped `lscr.io/linuxserver/code-server` from 4.117.0 to 4.118.0.
- Bumped `lscr.io/linuxserver/homeassistant` from 2026.4.4 to 2026.5.0.

## [2026-05-06]

### Added
- `docker/netbootxyz/autoexec.ipxe` — forces `netboot.xyz.efi` to chainload the bundled `menu.ipxe` over TFTP instead of fetching `https://boot.netboot.xyz/menu.ipxe`, so PXE works on networks without outbound HTTPS / public DNS.
- `docker/netbootxyz/custom-menu/local-vars.ipxe` — sets `${custom_url}` so the upstream netboot.xyz menu auto-surfaces a "Custom URL Menu" entry pointing at the local nginx. No upstream-shipped file is modified.
- `docker/netbootxyz/custom-menu/custom.ipxe` — custom iPXE menu with a working Fedora 44 Workstation Live entry (boots over HTTP from `/assets/fedora-44-live/`). Works around upstream netboot.xyz [issue #1758](https://github.com/netbootxyz/netboot.xyz/issues/1758).
- `docker/netbootxyz/custom-cont-init.d/99-chown-custom-menu` — linuxserver init hook that chowns the bind-mounted custom menu files to the in-container `nbxyz` user (uid 1000) on start, satisfying `dnsmasq --tftp-secure`. Required because Portainer's git checkout creates files as root. Only chowns files this stack owns — never modifies upstream-managed files.
- `docker/netbootxyz/scripts/setup-fedora-live.sh` — downloads a Fedora Workstation Live ISO and extracts kernel/initrd/squashfs into the assets directory. Supports both old (`/images/pxeboot/`) and new (`/boot/x86_64/loader/`) ISO layouts.

### Changed
- Bumped `ghcr.io/netbootxyz/netbootxyz` from `0.7.6-nbxyz4` to `0.7.6-nbxyz18`.
- Wired the custom menu and autoexec into `docker/netbootxyz/docker-compose.yml` as three read-only file bind mounts (`autoexec.ipxe`, `local-vars.ipxe` → `/config/menus/`; `custom.ipxe` → `/assets/custom-menu/`). All target paths are user-defined files that upstream never ships, so `MENU_VERSION` upgrades and image refreshes cannot clobber them — no init hook or post-deploy script required.
- Updated `docker/netbootxyz/README.md` with the new design.

### Dependencies
- Bumped `traefik` from v3.6.15 to v3.7.0.
- Bumped `ollama/ollama` from 0.23.0 to 0.23.1.

## [2026-05-05]

### Dependencies
- Bumped `nicotsx/zerobyte` from v0.35.0 to v0.36.0.

## [2026-05-04]

### Dependencies
- Bumped `homarr-labs/homarr` from v1.59.3 to v1.60.0.
- Bumped `ollama/ollama` from 0.22.1 to 0.23.0.
- Bumped `rackulalives/rackula` from v0.9.3-persist to v0.9.4-persist.
- Bumped `rackulalives/rackula-api` from 0.9.3 to 0.9.4.

## [2026-05-01]

### Dependencies
- Bumped `ollama/ollama` from 0.22.0 to 0.22.1.

## [2026-04-30]

### Dependencies
- Bumped `traefik` from v3.6.14 to v3.6.15.

## [2026-04-29]

### Dependencies
- Bumped `alexta69/metube` from 2026.04.26 to 2026.04.28.
- Bumped `ollama/ollama` from 0.21.2 to 0.22.0.

## [2026-04-28]

### Dependencies
- Bumped `netdata/netdata` from v2.10.2 to v2.10.3.

## [2026-04-27]

### Dependencies
- Bumped `homarr-labs/homarr` from v1.59.2 to v1.59.3.
- Bumped `linuxserver/homeassistant` from 2026.4.3 to 2026.4.4.
- Bumped `alexta69/metube` from 2026.04.21 to 2026.04.26.
- Bumped `open-webui/open-webui` from v0.9.1 to v0.9.2.
- Bumped `stirling-tools/stirling-pdf` from 2.9.2 to 2.10.0.

## [2026-04-24]

### Dependencies
- Bumped `linuxserver/code-server` from 4.116.0 to 4.117.0.
- Bumped `ollama/ollama` from 0.21.1 to 0.21.2.

## [2026-04-23]

### Dependencies
- Bumped `ollama/ollama` from 0.21.0 to 0.21.1.
- Bumped `traefik` from v3.6.13 to v3.6.14.

## [2026-04-22]

### Dependencies
- Bumped `alexta69/metube` from 2026.04.18 to 2026.04.21.
- Bumped `open-webui/open-webui` from v0.9.0 to v0.9.1.

## [2026-04-21]

### Dependencies
- Bumped `linuxserver/ombi` from 4.53.4 to 4.53.5.
- Bumped `open-webui/open-webui` from v0.8.12 to v0.9.0.
- Bumped `nicotsx/zerobyte` from v0.34.0 to v0.35.0.

## [2026-04-20]

### Dependencies
- Bumped `homarr-labs/homarr` from v1.59.1 to v1.59.2.
- Bumped `linuxserver/homeassistant` from 2026.4.2 to 2026.4.3.
- Bumped `alexta69/metube` from 2026.04.16 to 2026.04.18.

## [2026-04-19]

### Dependencies
- Bumped `linuxserver/code-server` from 4.115.0 to 4.116.0.
- Bumped `linuxserver/kasm` from 1.18.0 to 1.18.1.
- Bumped `alexta69/metube` from 2026.04.13 to 2026.04.16.
- Bumped `ollama/ollama` from 0.20.7 to 0.21.0.

## [2026-04-15]

### Dependencies
- Bumped `netdata/netdata` from v2.10.1 to v2.10.2.

## [2026-04-14]

### Dependencies
- Bumped `homarr-labs/homarr` from v1.58.1 to v1.59.1.
- Bumped `linuxserver/homeassistant` from 2026.4.1 to 2026.4.2.
- Bumped `alexta69/metube` from 2026.04.10 to 2026.04.13.
- Bumped `netdata/netdata` from v2.10.0 to v2.10.1.
- Bumped `ollama/ollama` from 0.20.5 to 0.20.7.
- Bumped `nicotsx/zerobyte` from v0.33.1 to v0.34.0.

## [2026-04-10]

### Dependencies
- Bumped `linuxserver/code-server` from 4.114.1 to 4.115.0.
- Bumped `alexta69/metube` from 2026.04.05 to 2026.04.10.
- Bumped `netdata/netdata` from v2.9.0 to v2.10.0.
- Bumped `ollama/ollama` from 0.20.3 to 0.20.5.

## [2026-04-08]

### Dependencies
- Bumped `tailscale/tailscale` from v1.94.2 to v1.96.5.
- Bumped `traefik` from v3.6.12 to v3.6.13.

## [2026-04-07]

### Dependencies
- Bumped `linuxserver/code-server` from 4.114.0 to 4.114.1.
- Bumped `ollama/ollama` from 0.20.2 to 0.20.3.

## [2026-04-06]

### Dependencies
- Bumped `henrygd/beszel` and `henrygd/beszel-agent-intel` from 0.18.6 to 0.18.7.
- Bumped `linuxserver/code-server` from 4.113.0 to 4.114.0.
- Bumped `homarr-labs/homarr` from v1.57.1 to v1.58.1.
- Bumped `linuxserver/homeassistant` from 2026.4.0 to 2026.4.1.
- Bumped `alexta69/metube` from 2026.04.02 to 2026.04.05.
- Bumped `ollama/ollama` from 0.20.0 to 0.20.2.
- Bumped `stirling-tools/stirling-pdf` from 2.9.0 to 2.9.2.
- Bumped `nicotsx/zerobyte` from v0.33.0 to v0.33.1.

## [2026-04-04]

### Added
- Added Storj Node service (`docker/storj-node/`) — decentralized cloud storage node operator with environment-based configuration for wallet, address, bandwidth, and storage allocation.

## [2026-04-03]

### Dependencies
- Bumped `linuxserver/code-server` from 4.112.0 to 4.113.0.
- Bumped `ollama/ollama` from 0.19.0 to 0.20.0.
- Bumped `stirling-tools/stirling-pdf` from 2.8.0 to 2.9.0.

## [2026-04-02]

### Dependencies
- Bumped Terraform `scalecomputing/hypercore` provider from 1.2.0 to 1.4.0 across all modules.
- Bumped `linuxserver/homeassistant` from 2026.3.4 to 2026.4.0.
- Bumped `alexta69/metube` from 2026.03.21 to 2026.04.02.
- Bumped `nicotsx/zerobyte` from v0.32.4 to v0.33.0.

## [2026-04-01]

### Dependencies
- Bumped `nickfedor/watchtower` from 1.15.0 to 1.16.1.

## [2026-03-30]

### Dependencies
- Bumped `henrygd/beszel` and `henrygd/beszel-agent-intel` from 0.18.4 to 0.18.6.
- Bumped `homarr-labs/homarr` from v1.56.1 to v1.57.1.
- Bumped `ollama/ollama` from 0.18.3 to 0.19.0.

## [2026-03-27]

### Dependencies
- Bumped `open-webui/open-webui` from v0.8.11 to v0.8.12.
- Bumped `traefik` from v3.6.11 to v3.6.12.

## [2026-03-26]

### Dependencies
- Bumped `open-webui/open-webui` from v0.8.10 to v0.8.11.
- Bumped `ollama/ollama` from 0.18.2 to 0.18.3.
- Bumped `rackulalives/rackula` from v0.9.2-persist to v0.9.3-persist.
- Bumped `rackulalives/rackula-api` from 0.9.2 to 0.9.3.

## [2026-03-25]

### Dependencies
- Bumped `stirling-tools/stirling-pdf` from 2.7.3 to 2.8.0.
- Bumped `nickfedor/watchtower` from 1.14.4 to 1.15.0.

## [2026-03-24]

### Dependencies
- Bumped `linuxserver/homeassistant` from 2026.3.3 to 2026.3.4.
- Bumped `nicotsx/zerobyte` from v0.32.3 to v0.32.4.

## [2026-03-23]

### Dependencies
- Bumped `jlesage/handbrake` from v26.03.2 to v26.03.3.
- Bumped `homarr-labs/homarr` from v1.56.0 to v1.56.1.
- Bumped `linuxserver/homeassistant` from 2026.3.2 to 2026.3.3.
- Bumped `alexta69/metube` from 2026.03.18 to 2026.03.21.
- Bumped `nicotsx/zerobyte` from v0.32.1 to v0.32.3.

## [2026-03-20]

### Added
- Added `homelab-architecture.excalidraw` — visual homelab architecture diagram.
- Added Mermaid architecture diagram to `README.md` showing service topology, network groups, GPU services, and external dependencies.
- Added `LICENSE` (MIT).

## [2026-03-19]

### Changed
- Simplified Dependabot configuration for docker-compose, Terraform, and GitHub Actions ecosystems.
- Added `line-length` rule to `.github/.yamllint` configuration.
- Updated environment variable syntax in docker-compose files for consistency across services.
- Added shell scripting best practices, Terraform conventions, and heredoc-prevention instruction files to `.github/instructions/`.
- Added new Copilot skills and prompts (model recommendation, refactor planning, secret scanning, GitHub Copilot agent suggestions).
- Added sub-issue, issue template, and secret scanning feature documentation.
- Updated scripts and workflows for improved functionality and consistency.

### Dependencies
- Bumped `linuxserver/code-server` from 4.111.0 to 4.112.0.
- Bumped `stirling-tools/stirling-pdf` from 2.7.2 to 2.7.3.
- Bumped `traefik` from v3.6.10 to v3.6.11.
- Bumped Terraform `scalecomputing/hypercore` from 1.2.0 to 1.4.0.
- Bumped Terraform `hashicorp/random` from 3.7.2 to 3.8.1.
- Bumped Terraform `vultr/vultr` from 2.27.1 to 2.30.1.

## [2026-03-18]

### Added
- Added Rackula service (`docker/rackula/`) — drag-and-drop rack layout designer with persistent storage.
  - Frontend: `ghcr.io/rackulalives/rackula:v0.9.2-persist` served via Traefik at `rackula.${TRAEFIK_BASE_DOMAIN}`
  - API sidecar: `ghcr.io/rackulalives/rackula-api:0.9.2` for layout persistence
  - Supports optional local and OIDC authentication modes
  - Data persisted to `${DOCKER_BASE_PATH}/rackula/data`

### Fixed
- `docker/rackula/docker-compose.yml` — changed `RACKULA_LISTEN_PORT` and Traefik load balancer port from non-standard to `80` for correct HTTP routing.

### Dependencies
- Bumped `stirling-tools/stirling-pdf` from 2.7.1 to 2.7.2.
- Bumped `nicotsx/zerobyte` from v0.32.0 to v0.32.1.
- Bumped `jlesage/handbrake` from v26.02.2 to v26.03.2.
- Bumped `homarr-labs/homarr` from v1.55.0 to v1.56.0.
- Bumped `alexta69/metube` from 2026.03.08 to 2026.03.18.
- Bumped `ollama/ollama` from 0.17.7 to 0.18.1.
- Bumped `nickfedor/watchtower` from 1.14.3 to 1.14.4.
- Bumped `linuxserver/homeassistant` from 2026.3.1 to 2026.3.2.

## [2026-03-12]

### Dependencies
- Bumped `stirling-tools/stirling-pdf` from 2.5.3 to 2.7.0.
- Bumped `linuxserver/homeassistant` from 2026.2.3 to 2026.3.1.
- Bumped `ollama/ollama` from 0.17.6 to 0.17.7.
- Bumped `homarr-labs/homarr` from v1.54.0 to v1.55.0.
- Bumped `alexta69/metube` from 2026.03.03 to 2026.03.08.
- Bumped `open-webui/open-webui` from 0.8.8 to v0.8.10.
- Bumped `linuxserver/code-server` from 4.109.5 to 4.111.0.
- Bumped `traefik` from 3.6.9 to v3.6.10.
- Bumped `nicotsx/zerobyte` from v0.29.2 to v0.31.0.

## [2026-03-04]

### Dependencies
- Bumped `nicotsx/zerobyte` from v0.28.2 to v0.29.2.
- Bumped `ollama/ollama` from 0.17.0 to 0.17.6.
- Bumped `alexta69/metube` from 2026.02.22 to 2026.03.03.
- Bumped `open-webui/open-webui` from 0.8.5 to 0.8.8.
- Bumped `homarr-labs/homarr` from v1.53.2 to v1.54.0.
- Bumped `linuxserver/code-server` from 4.109.2 to 4.109.5.
- Bumped `nickfedor/watchtower` from 1.14.2 to 1.14.3.

## [2026-02-24]

### Dependencies
- Bumped `netdata/netdata` from v2.8.5 to v2.9.0.
- Bumped `stirling-tools/stirling-pdf` from 2.4.6 to 2.5.3.
- Bumped `open-webui/open-webui` from 0.8.1 to 0.8.5.
- Bumped `ollama/ollama` from 0.16.1 to 0.17.0.
- Bumped `alexta69/metube` from 2026.02.14 to 2026.02.22.
- Bumped `nicotsx/zerobyte` from v0.27.0 to v0.28.2.
- Bumped `nickfedor/watchtower` from 1.14.1 to 1.14.2.
- Bumped `jlesage/handbrake` from v26.01.1 to v26.02.2.
- Bumped `henrygd/beszel` and `henrygd/beszel-agent-intel` from 0.18.3 to 0.18.4.
- Bumped `homarr-labs/homarr` from v1.53.1 to v1.53.2.
- Bumped `linuxserver/homeassistant` from 2026.2.2 to 2026.2.3.
- Bumped `traefik` from 3.6.8 to 3.6.9.

## [2026-02-11]

### Fixed
- `docker/kasm/docker-compose.yml` — added `/dev/dri` device mapping for Intel GPU hardware acceleration in Kasm.

## [2026-02-07]

### Fixed
- `docker/kasm/docker-compose.yml` — added default `proxynet` network, setup wizard router with correct scheme, missing service label for Kasm router, and missing scheme configuration for setup service.
- `docker/kasm/README.md` — updated reverse proxy configuration instructions and post-setup wizard steps.

## [2026-02-14]

### Added
- Added Kasm Workspaces service (`docker/kasm/`) — browser-based Linux desktop environment with GPU acceleration.
  - Image: `lscr.io/linuxserver/kasm:1.18.0` served via Traefik at `kasm.${TRAEFIK_BASE_DOMAIN}`
  - Configured with `/dev/dri` device mapping for GPU hardware acceleration and dual Traefik router (main + setup wizard)
  - Data persisted to `${DOCKER_BASE_PATH}/kasm`

### Changed
- Identified and documented Dependabot limitation with Plex's non-standard versioning scheme (`MAJOR.MINOR.PATCH.BUILD-COMMITHASH`).
- Established manual update process for Plex version management going forward.

### Dependencies
- Bumped `plexinc/pms-docker` to 1.43.0.10492-121068a07 (manual update, Dependabot cannot handle Plex's non-standard versioning).
- Bumped `homarr-labs/homarr` from v1.52.0 to v1.53.1.
- Bumped `linuxserver/homeassistant` from 2026.1.3 to 2026.2.2.
- Bumped `alexta69/metube` from 2026.01.30 to 2026.02.14.
- Bumped `ollama/ollama` from 0.15.2 to 0.16.1.
- Bumped `stirling-tools/stirling-pdf` from 2.4.2 to 2.4.6.
- Bumped `linuxserver/code-server` from 4.108.2 to 4.109.2.
- Bumped `open-webui/open-webui` from v0.7.2 to 0.8.1.
- Bumped `tailscale/tailscale` from v1.92.5 to v1.94.2.
- Bumped `nicotsx/zerobyte` from v0.24.2 to v0.27.0.
- Bumped `traefik` from 3.6.7 to 3.6.8.
- Bumped `henrygd/beszel` and `henrygd/beszel-agent-intel` from 0.18.2 to 0.18.3.
- Bumped `nickfedor/watchtower` from 1.14.0 to 1.14.1.

## [2026-01-31]

### Changed
- Enhanced Copilot instructions with detailed environment configuration documentation.
- Improved Dependabot automation details in documentation.
- Changed Dependabot docker-compose update schedule from weekly to daily for faster security updates.
- Added `APP_SECRET` and `BASE_URL` environment variables to Zerobyte configuration.

### Dependencies
- Bumped `traefik` from 3.6.6 to 3.6.7.
- Bumped `plexinc/pms-docker` to 1.43.0.10467-2b1ba6e69.
- Bumped `nickfedor/watchtower` to 1.14.0.
- Bumped `nicotsx/zerobyte` to v0.24.2.
- Bumped `homarr-labs/homarr` to v1.52.0.
- Bumped `alexta69/metube` to 2026.01.30.
- Bumped `ollama/ollama` to 0.15.2.
- Bumped `stirling-tools/stirling-pdf` to 2.4.2.
- Bumped `linuxserver/code-server` to 4.108.2.

## [2026-01-24]

### Dependencies
- Bumped `homarr-labs/homarr` to v1.51.0.
- Bumped `linuxserver/homeassistant` to 2026.1.3.
- Bumped `alexta69/metube` to 2026.01.24.
- Bumped `netdata/netdata` to v2.8.5.
- Bumped `ollama/ollama` to 0.15.1.

## [2026-01-17]

### Dependencies
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.18.2.
- Bumped `henrygd/beszel/beszel` to 0.18.2.
- Bumped `linuxserver/code-server` to 4.108.1.
- Bumped `homarr-labs/homarr` to v1.50.0.
- Bumped `linuxserver/homeassistant` to 2026.1.2.

## [2026-01-10]

### Added
- Added Zerobyte service for automated backup management and file versioning.
- Added comprehensive Zerobyte documentation with environment configuration details.
- Added `/mnt` volume mount to Zerobyte for flexible backup target configuration.

### Fixed
- Corrected formatting of `TRUSTED_ORIGINS` comment in Zerobyte docker-compose.yml.

### Dependencies
- Bumped `open-webui/open-webui` to v0.7.2.
- Bumped `stirling-tools/stirling-pdf` to 2.4.1.
- Bumped `traefik` from 3.6.2 to 3.6.6.
- Bumped `alexta69/metube` to 2026.01.10.
- Bumped `linuxserver/ombi` from 4.47.1 to 4.53.4.
- Bumped `linuxserver/code-server` to 4.107.1.
- Bumped `tailscale/tailscale` to v1.92.5.
- Bumped `jlesage/handbrake` to v26.01.1.
- Bumped `homarr-labs/homarr` to v1.49.0.
- Bumped `linuxserver/homeassistant` to 2026.1.1.

## [2026-01-07]

### Fixed
- Updated Watchtower image to version 1.13.1.

## [2026-01-03]

### Dependencies
- Bumped `homarr-labs/homarr` to v1.48.0.
- Bumped `linuxserver/homeassistant` to 2025.12.5.
- Bumped `alexta69/metube` to 2026.01.03.
- Bumped `ollama/ollama` to 0.15.0.
- Bumped `stirling-tools/stirling-pdf` to 2.4.0.

## [2025-12-27]

### Dependencies
- Bumped `jlesage/handbrake` to v25.12.1.
- Bumped `homarr-labs/homarr` to v1.47.0.
- Bumped `alexta69/metube` to 2025.12.27.
- Bumped `netdata/netdata` to v2.8.4.
- Bumped `open-webui/open-webui` to v0.6.43.

## [2025-12-20]

### Dependencies
- Bumped `tailscale/tailscale` to v1.92.0.
- Bumped `jlesage/handbrake` to v25.11.2.
- Bumped `homarr-labs/homarr` to v1.46.0.
- Bumped `linuxserver/code-server` to 4.107.0.
- Bumped `linuxserver/homeassistant` to 2025.12.3.

## [2025-12-13]

### Dependencies
- Bumped `jlesage/handbrake` to v25.11.1.
- Bumped `homarr-labs/homarr` to v1.45.0.
- Bumped `peter-evans/create-pull-request` from 7 to 8 in GitHub Actions workflows.
- Bumped `linuxserver/homeassistant` to 2025.12.2.
- Bumped `netdata/netdata` to v2.8.3.
- Bumped `alexta69/metube` to 2025.12.13.

## [2025-12-06]

### Dependencies
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.18.0.
- Bumped `henrygd/beszel/beszel` to 0.18.0.
- Bumped `linuxserver/code-server` to 4.106.2.
- Bumped `homarr-labs/homarr` to v1.44.0.
- Bumped `linuxserver/homeassistant` to 2025.12.1.

## [2025-11-29]

### Dependencies
- Bumped `homarr-labs/homarr` to v1.43.4.
- Bumped `alexta69/metube` to 2025.11.29.
- Bumped `open-webui/open-webui` to v0.6.42.
- Bumped `stirling-tools/stirling-pdf` to 1.6.0.
- Bumped `tailscale/tailscale` to v1.90.8.

## [2025-11-25]

### Added
- Added `vm-cluster` Terraform module for deploying clusters of multiple identical VMs (default: 3 nodes, configurable 1-10).
- Added automatic cluster node naming (`<cluster_name>-node-N`) and tagging (`cluster:<name>`, `node:<number>`).
- Added comprehensive cluster outputs: node information, VM names, and individual passwords.

### Changed
- Updated `terraform/test/main.tf` to use `vm-cluster` module instead of single VM example.
- Updated `terraform/test/outputs.tf` with cluster-specific outputs (nodes, VM names, passwords).
- Added `TS_SOCKET` environment variable to Code-Server Tailscale configuration for explicit socket path control.
- Updated Code-Server `.env.example` with `TS_SOCKET=/var/run/tailscale/tailscaled.sock` default value.

## [2025-11-24]

### Changed
- Migrated Code-Server from external custom-cont-init.d scripts to LinuxServer.io docker-mods architecture.
- Replaced external `code-server-scripts` repository dependency with local initialization scripts.
- Implemented hybrid installation approach using docker-mods, universal-package-install, and custom scripts.
- Updated Code-Server docker-compose.yml to use 6 docker-mods for core development tools.
- Consolidated all Code-Server documentation into single README.md with table of contents.
- Enhanced Code-Server README.md with comprehensive sections for deployment, verification, troubleshooting, and customization.

### Added
- Added docker-mods for Code-Server: PowerShell, Docker CLI, AWS CLI, Terraform, Python3, and universal-package-install.
- Added `INSTALL_PACKAGES` environment variable for system utilities installation (11 packages).
- Added `custom-cont-init.d/install-additional-tools.sh` script for 1Password CLI, Packer, AWS Session Manager, aws-vault, tfenv, lacework-cli, and k9s.
- Added `custom-cont-init.d/README.md` documenting custom initialization script functionality.
- Added `custom-cont-init.d/.gitattributes` to ensure proper line endings for shell scripts.

### Removed
- Removed volume mount to external `code-server-scripts` repository.
- Removed dependency on external GitHub repository for initialization scripts.
- Removed MIGRATION.md and QUICK-REFERENCE.md in favor of consolidated README.md.

## [2025-11-23]

### Added
- Added descriptive comments to docker-compose files explaining host network mode usage (Plex, Netdata, Beszel-agent).
- Added comment explaining iVentoy direct port mappings for PXE/TFTP/HTTP boot services.
- Added comment for netbootxyz TFTP UDP port requirement.
- Added comment for Traefik dashboard port mapping (8181:8080).
- Added comprehensive VM module documentation (`terraform/modules/vm/README.md`) with 126 lines detailing configuration options, usage examples, and best practices.
- Added complete VM module structure with `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf` files.
- Added random password generation for Ubuntu VM users in Terraform test configuration.
- Added new outputs for VM password and configuration details in `terraform/test/outputs.tf`.

### Changed
- Improved Traefik configuration log level from DEBUG to INFO for production readiness.
- Enhanced traefik.yaml log level documentation with usage guidance.
- Standardized Traefik label ordering across all services (enable, service port, router rule, entrypoints, tls, certresolver).
- Improved Terraform code formatting and comment consistency across modules.
- Enhanced memory unit comments in Terraform configurations (added GB conversion).
- Improved Portainer note formatting in Traefik docker-compose.yml.
- Refactored VM configuration in `terraform/test/main.tf` to use local Ubuntu server templates instead of remote resources.
- Updated VM affinity strategy to include node 2 for better load distribution.
- Enabled package upgrades in cloud-config for Ubuntu user data templates.
- Cleaned up VM configuration by removing commented-out code and unused affinity settings (28 lines removed).
- Updated Terraform provider versions in `terraform/test/.terraform.lock.hcl`.

### Fixed
- Fixed trailing whitespace in cloud-images module comments.
- Standardized comment formatting for better maintainability.
- Removed deprecated virtual disk resource from VM configuration in favor of cloud-init approach.

### Added
- Added comprehensive GitHub Copilot prompts for educational commenting, memory keeping, and project documentation.
- Added prompts for folder structure analysis, GitHub setup, and coding standards generation.

### Changed
- Added `TZ` environment variable to Homarr service for timezone consistency.
- Added `TZ` environment variable to Stirling-PDF service for timezone consistency.
- Added `TZ` environment variable to MeTube service for timezone consistency.
- Added `TZ` environment variable to Beszel service for timezone consistency.
- Added `TZ` environment variable to Watchtower service for timezone consistency.
- Added `TZ` environment variable to IT Tools service for timezone consistency.
- Added `TZ` environment variable to iVentoy service for timezone consistency.
- Updated README.md to reflect correct Traefik version (v3.6.2 instead of v3.4.4).
- Enhanced Copilot instructions with detailed CHANGELOG.md update guidelines and version pinning requirements.

### Fixed
- Added missing `TZ=America/Los_Angeles` variable to Homarr `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to Beszel `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to MeTube `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to Stirling-PDF `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to IT Tools `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to iVentoy `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to Watchtower `.env.example`.
- Added missing `TZ=America/Los_Angeles` variable to Netdata `.env.example`.
- Standardized timezone configuration across all services to ensure compliance with architecture standards.

### Dependencies
- Bumped `stirling-tools/stirling-pdf` from 1.3.2 to 1.5.0.
- Bumped `traefik` from 3.5.2 to 3.6.2.
- Bumped `ollama/ollama` from 0.12.0 to 0.13.0.
- Bumped `open-webui/open-webui` from 0.6.30 to 0.6.36.
- Bumped `netdata/netdata` from v2.7.3 to v2.8.1.
- Bumped `linuxserver/code-server` from 4.105.1 to 4.106.2.
- Bumped `tailscale/tailscale` from v1.90.6 to v1.90.8.
- Bumped `homarr-labs/homarr` from v1.43.3 to v1.44.0.
- Bumped `alexta69/metube` from 2025.11.13 to 2025.11.16.

## [2025-11-22]

### Added
- Added Networking Toolbox service (Lissy93) for web-based network diagnostics and utilities.
- Added Docker Compose configuration for Lissy93 Networking Toolbox with 100+ tools.
- Added comprehensive documentation for DNS, SSL/TLS, conversion, and security tools.
- Added offline-first, privacy-focused web interface accessible via Traefik.

### Changed
- Enhanced image version pinning guidelines in Copilot instructions with registry checking steps.

### Fixed
- Corrected image tag format in README and docker-compose files for consistency.

### Dependencies
- Bumped `actions/checkout` from 5 to 6 in GitHub Actions workflows.

## [2025-11-15]

### Changed
- Added apparmor security option to Beszel-Agent for enhanced security.
- Added D-Bus system bus socket volume to Beszel-Agent for system integration.

### Dependencies
- Bumped `henrygd/beszel/beszel` from 0.15.4 to 0.16.1.
- Bumped `henrygd/beszel/beszel-agent-intel` from 0.15.4 to 0.16.1.
- Bumped `homarr-labs/homarr` from v1.43.2 to v1.43.3.
- Bumped `linuxserver/homeassistant` from 2025.11.1 to 2025.11.2.
- Bumped `alexta69/metube` from 2025.10.23 to 2025.11.13.

## [2025-11-08]

### Changed
- Improved comments in Beszel docker-compose.yml for better clarity.
- Updated README and .env.example with new optional configuration options for Beszel.

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.15.4.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.15.4.
- Bumped `homarr-labs/homarr` to v1.43.2.
- Bumped `linuxserver/homeassistant` to 2025.11.1.
- Bumped `netdata/netdata` to v2.7.3.

## [2025-11-01]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.14.3.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.14.3.
- Bumped `tailscale/tailscale` to v1.90.6.
- Bumped `homarr-labs/homarr` to v1.43.1.
- Bumped `alexta69/metube` to 2025.10.23.

## [2025-10-25]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.14.0.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.14.0.
- Bumped `linuxserver/code-server` to 4.105.1.
- Bumped `homarr-labs/homarr` to v1.43.0.
- Bumped `linuxserver/homeassistant` to 2025.10.3.

## [2025-10-18]

### Dependencies
- Bumped `linuxserver/code-server` to 4.104.2.
- Bumped `tailscale/tailscale` to v1.88.0.
- Bumped `jlesage/handbrake` to v25.10.1.
- Bumped `homarr-labs/homarr` to v1.42.1.
- Bumped `linuxserver/homeassistant` to 2025.10.1.

## [2025-10-12]

### Changed
- Updated Terraform provider configurations and hashes in templates.

## [2025-10-11]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.13.1.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.13.1.
- Bumped `linuxserver/code-server` to 4.104.1.
- Bumped `homarr-labs/homarr` to v1.42.0.
- Bumped `linuxserver/homeassistant` to 2025.9.3.

## [2025-10-04]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.13.0.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.13.0.
- Bumped `tailscale/tailscale` to v1.86.0.
- Bumped `homarr-labs/homarr` to v1.41.0.
- Bumped `jlesage/handbrake` to v25.09.1.

## [2025-09-28]

### Changed
- Switched Beszel-Agent to Intel-specific image (`beszel-agent-intel`) for hardware acceleration support.
- Added GPU device mapping (`/dev/dri`) to Beszel-Agent for Intel GPU metrics.
- Added additional capabilities (CAP_PERFMON, CAP_SYS_ADMIN, CAP_DAC_OVERRIDE) to Beszel-Agent for system monitoring.

## [2025-09-27]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.12.12.
- Bumped `henrygd/beszel/beszel-agent-intel` to 0.12.12 (first Intel-specific version).
- Bumped `linuxserver/code-server` to 4.103.1.
- Bumped `homarr-labs/homarr` to v1.40.0.
- Bumped `alexta69/metube` to 2025.09.27.

## [2025-09-20]

### Dependencies
- Bumped `tailscale/tailscale` to v1.84.0.
- Bumped `linuxserver/code-server` to 4.103.0.
- Bumped `homarr-labs/homarr` to v1.39.0.
- Bumped `linuxserver/homeassistant` to 2025.9.2.
- Bumped `ollama/ollama` to 0.12.0.

## [2025-09-17]

### Added
- Added Home Assistant service for home automation and IoT device management.
- Added comprehensive Home Assistant documentation with device integration guidance.
- Added privileged mode support for USB device access (Zigbee/Z-Wave dongles).
- Added network discovery capabilities for smart home device integration.
- Added timezone standardization guidance requiring `TZ=America/Los_Angeles` across all services.

### Changed
- Updated repository documentation to enforce `America/Los_Angeles` timezone standard.
- Updated Copilot instructions to include timezone consistency requirements.
- Updated Home Assistant to use LinuxServer.io image (`lscr.io/linuxserver/homeassistant:2024.9.3`) for better file permissions and consistency with other services.
- Changed Home Assistant from `latest` tag to pinned version `2024.9.3` for stability and predictable deployments.

### Dependencies
- Bumped `open-webui/open-webui` to 0.6.30.
- Bumped `linuxserver/code-server` to 4.102.1.
- Bumped `henrygd/beszel/beszel` to 0.12.11.
- Bumped `henrygd/beszel/beszel-agent` to 0.12.11 (last non-Intel version).

## [2025-09-13]

### Dependencies
- Bumped `homarr-labs/homarr` to v1.38.0.
- Bumped `open-webui/open-webui` to 0.6.28.
- Bumped `traefik` from 3.5.1 to 3.5.2.
- Bumped `jlesage/handbrake` to v25.08.1.

## [2025-09-06]

### Dependencies
- Bumped `henrygd/beszel/beszel` to 0.12.9.
- Bumped `henrygd/beszel/beszel-agent` to 0.12.9.
- Bumped `homarr-labs/homarr` to v1.37.0.
- Bumped `alexta69/metube` to 2025.09.06.
- Bumped `stirling-tools/stirling-pdf` to 1.3.2.

## [2025-09-05]

### Added
- Added Netdata service for comprehensive real-time system monitoring.
- Added Docker container monitoring capabilities through Netdata.
- Added Netdata Cloud integration support for remote monitoring and alerts.
- Added comprehensive documentation for Netdata setup and configuration.

### Changed
- Updated project documentation to include Netdata service information.
- Removed unnecessary blank lines in docker-compose files for consistency.

### Fixed
- Improved comments in docker-compose.yml files for better clarity.

### Dependencies
- Bumped `stirling-tools/stirling-pdf` to 1.3.1.
- Bumped `ollama/ollama` to 0.11.0.
- Bumped `homarr-labs/homarr` to v1.36.0.
- Bumped `actions/setup-python` from 5 to 6 in GitHub Actions workflows.

## [2025-08-31]

### Added
- Added Webtop service with full desktop environment in browser support.
- Added Ombi service for media request management.
- Added comprehensive `.env.example` files for all services for better configuration management.
- Added Webtop service with GPU acceleration support (DRI3) and multiple desktop environments.
- Added documentation for all services including setup instructions and configuration details.

### Changed
- Updated MeTube Docker image to version `2025.08.28`.
- Updated Plex Docker image to version `1.42.1.10060-4e8b05daf`.
- Updated Traefik from version `3.5.0` to `3.5.1`.
- Updated Webtop configuration to increase shared memory size from 1GB to 3GB for better performance.
- Improved environment variable consistency across all services.
- Enhanced service documentation with detailed configuration options.

### Fixed
- Fixed Docker Compose comment formatting for MATE desktop environment in Webtop.
- Removed unused `.env` files and standardized `.env.example` files across services.
- Corrected Webtop network configuration to use `proxynet` external network.

### Dependencies
- Bumped `open-webui/open-webui` to latest version.
- Bumped `ollama/ollama` to latest version.
- Bumped `henrygd/beszel/beszel` to latest version.
- Bumped `henrygd/beszel/beszel-agent` to latest version.
- Bumped `homarr-labs/homarr` to latest version.
- Bumped `linuxserver/code-server` to latest version.
- Bumped `alexta69/metube` to latest version.

## [2025-07-27]

### Added
- Added Terraform configuration for Ubuntu cloud images and VM setup.

### Changed
- Updated Dependabot schedule to specify Saturday for all updates.

### Fixed
- Bumped `alexta69/metube` from 2025-07-01 to 2025-07-27.
- Bumped `homarr-labs/homarr` from v1.29.0 to v1.30.1.
- Bumped `linuxserver/code-server` to the latest version.
- Bumped `henrygd/beszel/beszel` from 0.11.1 to 0.12.1.
- Bumped `henrygd/beszel/beszel-agent` from 0.11.1 to 0.12.1.

## [2025-07-20]

### Added
- Added `it-tools` service to documentation and project structure.
- Added initial `.env` and `docker-compose.yml` for `code-server` service.
- Added `code-server` service to documentation and project structure.

### Changed
- Updated Traefik labels for `it-tools` service.
- Removed Nginx Proxy Manager from services list in documentation.

### Fixed
- Corrected middleware assignment for Beszel router in Docker Compose.
- Removed unnecessary middleware for X-Forwarded-For in Beszel router.

## [2025-07-19]

### Added
- Comprehensive Copilot instructions for Homelab GitOps.
- Debugging section in Copilot instructions.
- Initial `.env` and `docker-compose.yml` for `beszel` service.

### Changed
- Refactored YAML linting rules and improved formatting.
- Enhanced dependabot script to include GitHub Actions package ecosystem.

### Fixed
- Corrected middleware assignment for Beszel router in Docker Compose.

## [2025-07-12]

### Added
- Added `HandBrake` service to documentation and project structure.
- Added initial `.env` and `docker-compose.yml` for `iventoy` service.

### Changed
- Updated dependabot schedule to weekly.

## [2025-06-22]

### Added
- Added `stirling-pdf`, `nginx-proxy-manager`, `watchtower`, `plex`, and `homarr` services to Docker Compose.
- Initial commit.
