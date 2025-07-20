# Changelog

All notable changes to this project will be documented in this file.

## [2025-07-20]

### Added
- Added `it-tools` service to documentation and project structure.
- Added initial `.env` and `docker-compose.yml` for `code-server` service.

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
