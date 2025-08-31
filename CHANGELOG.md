# Changelog

All notable changes to this project will be documented in this file.

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
