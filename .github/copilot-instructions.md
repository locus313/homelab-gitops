# Copilot Instructions for Homelab GitOps

This document provides essential guidance for AI coding agents contributing to the Homelab GitOps repository. Follow these instructions to ensure consistency, quality, and alignment with project standards.

## Project Overview

Homelab GitOps is a repository for managing self-hosted services using Docker Compose and GitOps principles. It includes configurations for various services, automation scripts, and workflows.

## Key Components

### Services
- **Beszel**: Lightweight server monitoring.
- **HandBrake**: Video transcoder.
- **Homarr**: Homelab dashboard.
- **iVentoy**: PXE and USB boot server.
- **MeTube**: Video downloader.
- **NetbootXYZ**: Network boot server.
- **Plex**: Media server.
- **Stirling PDF**: PDF toolkit.
- **Traefik**: Reverse proxy and load balancer.
- **Watchtower**: Automated container updates.
- **IT Tools**: Collection of handy online tools for developers, self-hosted using Docker Compose.

### Automation
- **Dependabot**: Keeps Docker images up to date via `.github/dependabot.yml`.
- **GitHub Actions**: Includes workflows for YAML linting and Dependabot updates.
- **Watchtower**: Automatically updates running containers.

## Developer Workflows

### Deployment
1. **With Portainer Stacks**:
   - Use the Git repository option in Portainer to deploy a stack.
   - Specify the path to the desired service directory (e.g., `docker/traefik`).
   - Portainer will pull the latest `docker-compose.yml` and referenced files.

2. **Manual Deployment**:
   ```sh
   git clone https://github.com/yourusername/homelab-gitops.git
   cd homelab-gitops
   cd docker/<service-name>
   docker compose up -d
   ```

### Configuration
- Edit `.env` files in each service directory to match your environment.
- For Traefik, dynamic routing configurations are stored in `docker/traefik/config/dynamic/`.

### Testing
- Ensure all YAML files pass linting using the `.github/.yamllint` configuration.
- Run the `yaml-lint.yml` GitHub Actions workflow to validate YAML files.

### Debugging
- Use `docker logs <container-name>` to inspect logs for individual services.
- For Traefik, check logs in `docker/traefik/logs/` for routing and certificate issues.

## Project-Specific Conventions

- Use environment variables for sensitive data (e.g., `PLEX_CLAIM`, `SECRET_ENCRYPTION_KEY`).
- Follow the existing directory structure and naming conventions.
- Add meaningful comments for complex logic.
- Use relative paths for volume mounts in `docker-compose.yml` files where possible.

## Integration Points

- **Traefik**: Dynamic routing rules are defined in `docker/traefik/config/dynamic/`.
- **GitHub Actions**: Workflows are located in `.github/workflows/`.
- **Dependabot**: Configuration is auto-generated using `.github/scripts/generate-dependabot.sh`.

## Examples

### Traefik Dynamic Configuration
```yaml
http:
  routers:
    example-router:
      entryPoints:
        - websecure
      rule: 'Host(`example.${TRAEFIK_BASE_DOMAIN}`)'
      service: example-service
      tls:
        certResolver: cloudns
  services:
    example-service:
      loadBalancer:
        servers:
          - url: 'http://127.0.0.1:8080'
```

### Plex Environment Variables
```env
PUID=1000
PGID=1000
TZ=America/New_York
PLEX_CLAIM=claim-abc123
```

## Contribution Guidelines

- Include a clear description of changes in pull requests.
- Reference related issues.
- Ensure all tests pass before submission.
- Update `CHANGELOG.md` with concise descriptions of changes.

This document serves as a quick reference for AI agents to contribute effectively to the Homelab GitOps repository.
