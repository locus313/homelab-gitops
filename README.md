# homelab-gitops

This repository contains Docker Compose configurations and environment files for managing a self-hosted homelab using GitOps principles. It is designed for use with tools like Portainer Stacks (with Git integration) to enable automated, version-controlled deployments.

## Features

- Easy deployment and management of popular homelab services
- Environment-specific configuration using `.env` files
- Automated updates with Watchtower and Dependabot
- GitOps workflow for reproducible infrastructure
- Portainer Stacks support with Git-based updates

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Portainer](https://www.portainer.io/) (optional, for GitOps workflow)
- Git

## Overview

The following services are managed in this repository:

- **Homarr**: Dashboard for your homelab ([docker/homarr](docker/homarr))
- **MeTube**: Web GUI for downloading videos from YouTube and other sites ([docker/metube](docker/metube))
- **NetbootXYZ**: Network boot server for provisioning systems ([docker/netbootxyz](docker/netbootxyz))
- **Nginx Proxy Manager**: Reverse proxy with SSL support ([docker/nginx-proxy-manager](docker/nginx-proxy-manager))
- **Plex**: Media server ([docker/plex](docker/plex))
- **Stirling PDF**: PDF toolkit ([docker/stirling-pdf](docker/stirling-pdf))
- **Watchtower**: Automated Docker container updates ([docker/watchtower](docker/watchtower))
- **Traefik**: Modern reverse proxy and load balancer ([docker/traefik](docker/traefik))

Each service has its own directory with a `docker-compose.yml` and `.env` file for configuration.

## Repository Structure

```
docker/
  homarr/
    docker-compose.yml
    .env
  metube/
    docker-compose.yml
    .env
  netbootxyz/
    docker-compose.yml
    .env
  nginx-proxy-manager/
    docker-compose.yml
    .env
  plex/
    docker-compose.yml
    .env
  stirling-pdf/
    docker-compose.yml
    .env
  traefik/
    docker-compose.yml
    .env
  watchtower/
    docker-compose.yml
    .env
.github/
  dependabot.yml
  workflows/
    update-dependabot.yml
  scripts/
    generate-dependabot.sh
LICENSE
README.md
```

## Usage

### With Portainer Stacks (GitOps)

1. **Deploy a stack from this repository in Portainer:**
   - Use the Git repository option and specify the path to the desired service directory (e.g., `docker/traefik`).
   - Portainer will automatically pull the latest `docker-compose.yml` and any referenced files.

2. **Update configuration:**
   - Make changes to `.env` or `docker-compose.yml` in your Git repository.
   - In Portainer, click "Update the stack" to pull the latest changes and redeploy.

### Manual Deployment

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/homelab-gitops.git
   cd homelab-gitops
   ```

2. **Configure environment variables:**
   - Edit the `.env` files in each service directory under `docker/` to match your environment.

3. **Start a service:**
   ```sh
   cd docker/<service-name>
   docker compose up -d
   ```

4. **Stop a service:**
   ```sh
   docker compose down
   ```

## Automation

- **Dependabot**: Keeps Docker images up to date via [`.github/dependabot.yml`](.github/dependabot.yml).
- **GitHub Actions**: Workflow to update Dependabot config ([`.github/workflows/update-dependabot.yml`](.github/workflows/update-dependabot.yml)).
- **Watchtower**: Automatically updates running containers.
- **Portainer Stacks**: Enables GitOps-style updates for Docker Compose stacks.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License. See [LICENSE](LICENSE) for details.
