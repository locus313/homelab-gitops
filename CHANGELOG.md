# Changelog

All notable changes to this project will be documented in this file.

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
