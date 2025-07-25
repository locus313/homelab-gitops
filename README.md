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

- **Beszel**: Simple, lightweight server monitoring ([docker/beszel](docker/beszel))
- **HandBrake**: Video transcoder ([docker/handbrake](docker/handbrake))
- **Homarr**: Dashboard for your homelab ([docker/homarr](docker/homarr))
- **iVentoy**: PXE and USB boot server ([docker/iventoy](docker/iventoy))
- **MeTube**: Web GUI for downloading videos from YouTube and other sites ([docker/metube](docker/metube))
- **NetbootXYZ**: Network boot server for provisioning systems ([docker/netbootxyz](docker/netbootxyz))
- **Plex**: Media server ([docker/plex](docker/plex))
- **Stirling PDF**: PDF toolkit ([docker/stirling-pdf](docker/stirling-pdf))
- **Watchtower**: Automated Docker container updates ([docker/watchtower](docker/watchtower))
- **Traefik**: Modern reverse proxy and load balancer ([docker/traefik](docker/traefik))
- **IT Tools**: Collection of handy online tools for developers ([docker/it-tools](docker/it-tools))

Each service has its own directory with a `docker-compose.yml` and `.env` file for configuration.

## Repository Structure

```
docker/
  beszel/
    docker-compose.yml
    .env
  handbrake/
    docker-compose.yml
    .env
  homarr/
    docker-compose.yml
    .env
  iventoy/
    docker-compose.yml
    .env
  metube/
    docker-compose.yml
    .env
  netbootxyz/
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
  it-tools/
    docker-compose.yml
    .env
.github/
  dependabot.yml
  workflows/
    update-dependabot.yml
  scripts/
    generate-dependabot.sh
  .yamllint
LICENSE
README.md
```

## Usage

### With Portainer Stacks (GitOps)

1. **Deploy a stack from this repository in Portainer:**
   - Use the Git repository option and specify the path to the desired service directory (e.g., `docker/traefik`).
   - Portainer will automatically pull the latest `docker-compose.yml` and any referenced files, including static configuration files like `traefik.yml` if present.

2. **Update configuration:**
   - Make changes to `.env`, `docker-compose.yml`, or static config files (such as `traefik.yml` in `config/`) in your Git repository.
   - In Portainer, click "Update the stack" to pull the latest changes and redeploy.
   - **Note:** For Traefik, ensure your `docker-compose.yml` uses a relative bind mount for the config directory, for example:
     ```yaml
     volumes:
       - ./config:/etc/traefik:ro
     ```
     This ensures that `traefik.yml` and any other config files in the `config` directory are available to the container when deployed via Portainer Git stacks.
   - **Important:** The relative path bind mount feature for stacks is only available in Portainer Business Edition. If you are using Portainer Community Edition, you will need to use absolute paths or named volumes instead.

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

## Additional Features

### YAML Linting
- A `.github/.yamllint` configuration file is included to enforce YAML formatting rules.
- A GitHub Actions workflow ([`.github/workflows/yaml-lint.yml`](.github/workflows/yaml-lint.yml)) automatically lints YAML files on every push.

### Dependabot Enhancements
- Dependabot configuration is automatically generated using the `generate-dependabot.sh` script located in `.github/scripts/`.
- The `update-dependabot.yml` workflow ensures the `dependabot.yml` file stays up-to-date.

### Service-Specific Notes
- **Plex**: Requires a `PLEX_CLAIM` environment variable for server registration. Obtain it from [Plex](https://www.plex.tv/claim/).
- **Stirling PDF**: Includes advanced security and configuration options such as `SECURITY_ENABLELOGIN` and `SYSTEM_MAXFILESIZE`.
- **Homarr**: Requires a `SECRET_ENCRYPTION_KEY` for secure operations. Generate it using `openssl rand -hex 32`.

### Traefik Configuration
- Dynamic routing configurations are stored in `docker/traefik/config/dynamic/`.
- Example files include `storj-node-1.yaml` and `dh01.yaml`, which define routing rules and services.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License. See [LICENSE](LICENSE) for details.
