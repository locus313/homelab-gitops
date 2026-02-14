# Changelog

All notable changes to this project will be documented in this file.

## [2026-02-14]

### Changed
- Identified and documented Dependabot limitation with Plex's non-standard versioning scheme (`MAJOR.MINOR.PATCH.BUILD-COMMITHASH`).
- Established manual update process for Plex version management going forward.

### Dependencies
- Bumped `plexinc/pms-docker` to 1.43.0.10492-121068a07 (manual update, Dependabot cannot handle Plex's non-standard versioning).

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
