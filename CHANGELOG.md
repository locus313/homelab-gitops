# Changelog

All notable changes to this project will be documented in this file.

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
