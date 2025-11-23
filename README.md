# Homelab GitOps

A comprehensive repository for managing self-hosted services using Docker Compose and GitOps principles. This project provides configurations for various homelab services, automation scripts, and deployment workflows to streamline your self-hosted infrastructure management.

## Technology Stack

- **Containerization**: Docker, Docker Compose
- **Reverse Proxy**: Traefik v3.6.2
- **Orchestration**: Portainer (optional)
- **Infrastructure as Code**: Terraform with HyperCore provider
- **CI/CD**: GitHub Actions
- **Configuration Management**: Environment variables, YAML configurations
- **Monitoring**: Beszel (lightweight server monitoring), Netdata (comprehensive system monitoring)
- **Development Tools**: Code-Server, IT Tools, Stirling PDF, Webtop
- **Media Services**: Plex, Ombi, HandBrake, MeTube
- **Home Automation**: Home Assistant
- **Network Tools**: Networking Toolbox (100+ diagnostic utilities)
- **Network Boot**: iVentoy, NetbootXYZ

## Project Architecture

This project implements a **Traefik-First Architecture** using GitOps principles. All services communicate through a unified Docker network with Traefik as the single ingress point, providing automatic SSL certificate management and service discovery.

### Architecture Principles

1. **Single Ingress Point**: Traefik is the only service with exposed ports; all other services route through it
2. **Network Isolation**: All services communicate via the `proxynet` external Docker network
3. **Automatic Service Discovery**: Services use Traefik labels for dynamic routing configuration
4. **SSL Automation**: Let's Encrypt certificates via CloudNS DNS challenge (no port 80/443 required)
5. **GitOps Workflow**: Infrastructure as code with version control and automated deployments

### Architecture Diagram

```
Internet (HTTPS:443)
        │
        ▼
┌───────────────────────────────────────────────────────────┐
│                       Traefik                              │
│  - SSL Termination (Let's Encrypt + CloudNS)              │
│  - Dynamic Service Discovery (Docker labels)              │
│  - Automatic HTTPS Routing                                 │
└───────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────┐
│                 proxynet (External Network)                │
└───────────────────────────────────────────────────────────┘
        │
        ├─► Plex (Media Server)
        ├─► Ombi (Media Requests)
        ├─► Homarr (Dashboard)
        ├─► Code-Server (Browser IDE)
        ├─► Webtop (Linux Desktop)
        ├─► Beszel (Monitoring Hub)
        ├─► IT Tools (Developer Utilities)
        ├─► Networking Toolbox (Network Diagnostics)
        ├─► Home Assistant (Home Automation)
        ├─► HandBrake (Video Transcoding)
        ├─► MeTube (Video Downloader)
        ├─► Stirling PDF (PDF Tools)
        ├─► Open-WebUI (AI Interface)
        └─► Watchtower (Container Updates)

┌───────────────────────────────────────────────────────────┐
│  Netdata (Host Network - Direct Port :19999)              │
│  - System monitoring with real-time metrics               │
└───────────────────────────────────────────────────────────┘
```

### Standard Service Pattern

Every service follows this exact Docker Compose pattern:

```yaml
services:
  service-name:
    image: vendor/image:1.2.3  # Always pin versions, never use 'latest'
    container_name: service-name
    restart: unless-stopped
    networks:
      - proxynet
    volumes:
      - ${DOCKER_BASE_PATH}/service-name:/config
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
      TZ: ${TZ}  # Always use America/Los_Angeles
    labels:
      - traefik.enable=true
      - traefik.http.services.service-name.loadbalancer.server.port=8080
      - traefik.http.routers.service-name.rule=Host(`service-name.${TRAEFIK_BASE_DOMAIN}`)
      - traefik.http.routers.service-name.entrypoints=websecure
      - traefik.http.routers.service-name.tls=true
      - traefik.http.routers.service-name.tls.certresolver=cloudns

networks:
  proxynet:
    external: true
```

**Key Pattern Elements**:
- **Image Pinning**: Specific version tags for reproducible deployments
- **Network Configuration**: All services connect to external `proxynet`
- **Volume Mapping**: Uses `${DOCKER_BASE_PATH}` for consistent data storage
- **User Permissions**: `PUID`/`PGID` ensure proper file ownership
- **Traefik Labels**: Automatic service discovery and routing configuration

## Getting Started

### Prerequisites

- **Docker** (version 20.10+) and **Docker Compose** (version 2.0+) installed
- **Git** for repository management
- **(Optional) Portainer** for web-based stack management
- **Domain name** with DNS provider support (for SSL certificates via Let's Encrypt)
- **CloudNS account** for DNS challenge-based SSL certificate automation

### Critical First Steps

Before deploying any services, you **must** create the external Docker network that all services use for communication:

```bash
docker network create proxynet
```

**Note**: This network is required for Traefik-based service discovery and routing. All services connect to this network instead of exposing ports directly to the host.

### Installation

#### Option 1: Portainer Stacks (Recommended)

1. **Set up Portainer** with Git repository integration
2. **Create a new stack** using Git repository option
3. **Repository URL**: `https://github.com/yourusername/homelab-gitops.git`
4. **Compose path**: Specify the path to desired service (e.g., `docker/traefik`)
5. **Deploy** and Portainer will automatically pull configurations

#### Option 2: Manual Deployment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/homelab-gitops.git
   cd homelab-gitops
   ```

2. **Configure environment variables**:
   ```bash
   cd docker/<service-name>
   cp .env.example .env
   # Edit .env file with your specific values
   ```

3. **Deploy services**:
   ```bash
   docker compose up -d
   ```

### Service Deployment Order

**⚠️ CRITICAL**: Services must be deployed in this specific order:

1. **Deploy Traefik FIRST** (cornerstone service - reverse proxy and SSL termination):
   ```bash
   cd docker/traefik
   cp .env.example .env
   # Edit .env with CloudNS credentials and base domain
   docker compose up -d
   ```

2. **Verify Traefik is running**:
   - Access Traefik dashboard at `traefik.${TRAEFIK_BASE_DOMAIN}`
   - Check logs: `docker logs traefik`
   - Verify it's connected to `proxynet`: `docker network inspect proxynet`

3. **Deploy other services** in any order (they all depend on Traefik for routing)

## Environment Variables

Each service has its own environment configuration file. To configure a service:

1. Navigate to the service directory: `cd docker/<service-name>/`
2. Copy the example file: `cp .env.example .env`
3. Edit `.env` with your specific values

### Core Variables

Most services use these common environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOCKER_BASE_PATH` | Base path for Docker volumes | `/docker` |
| `PUID` | User ID for file permissions | `1000` |
| `PGID` | Group ID for file permissions | `1000` |
| `TZ` | Timezone (standardized) | `America/Los_Angeles` |
| `TRAEFIK_BASE_DOMAIN` | Base domain for services | `example.com` |

**Note**: All services should use `TZ=America/Los_Angeles` for consistency across the homelab environment.

### Service-Specific Variables

| Service | Additional Variables | Description |
|---------|---------------------|-------------|
| **Traefik** | `CLOUDNS_SUB_AUTH_ID`, `CLOUDNS_AUTH_PASSWORD` | SSL certificate automation |
| **Plex** | `PLEX_CLAIM`, `MEDIA_PATH` | Media server setup and storage |
| **Homarr** | `SECRET_ENCRYPTION_KEY` | Dashboard encryption |
| **Beszel** | `BESZEL_PUBLIC_KEY` | Monitoring agent authentication |
| **Netdata** | `NETDATA_CLAIM_TOKEN`, `NETDATA_CLAIM_ROOMS` | System monitoring and cloud integration |
| **HandBrake** | `MEDIA_PATH`, `BACKUP_PATH` | Video transcoding storage |
| **Code-Server** | `PASSWORD`, `TS_AUTHKEY` | IDE access and Tailscale |

Refer to each service's `.env.example` file for complete variable documentation.

## Project Structure

```
homelab-gitops/
├── docker/                 # Service configurations
│   ├── traefik/            # Reverse proxy and SSL termination
│   │   ├── config/         # Static and dynamic configurations
│   │   └── docker-compose.yml
│   ├── plex/               # Media server
│   ├── ombi/               # Media request management
│   ├── homarr/             # Homelab dashboard
│   ├── beszel/             # System monitoring
│   ├── netdata/            # Real-time system monitoring
│   ├── code-server/        # Browser-based IDE
│   ├── webtop/             # Linux desktop environment in browser
│   ├── networking-toolbox/ # Network diagnostics and utilities
│   └── [other-services]/   # Individual service directories
├── terraform/              # Infrastructure as code
│   ├── modules/            # Reusable Terraform modules
│   ├── templates/          # VM template configurations
│   └── test/               # Test environment configs
├── .github/                # GitHub workflows and documentation
│   ├── workflows/          # CI/CD pipelines
│   ├── scripts/            # Automation scripts
│   └── prompts/            # AI assistant prompts
└── README.md              # Project documentation
```

## Key Features

- **Automated Service Management**: Pre-configured Docker Compose setups for popular homelab services
- **SSL Certificate Automation**: Traefik integration with Let's Encrypt for automatic HTTPS
- **GitOps Workflow**: Version-controlled infrastructure with Portainer integration
- **Comprehensive Monitoring**: Beszel for lightweight system monitoring, Netdata for real-time system analytics
- **Service Dashboards**: Homarr for service management, Netdata for system performance monitoring
- **Development Environment**: Code-Server for browser-based development, Webtop for full Linux desktop environments
- **Desktop Access**: Webtop provides browser-accessible Linux desktops with GPU acceleration support
- **Network Diagnostics**: Networking Toolbox with 100+ tools for DNS, SSL/TLS, subnet calculations, and network analysis
- **Media Stack**: Plex media server with Ombi request management and HandBrake transcoding
- **Network Boot Services**: iVentoy and NetbootXYZ for PXE boot scenarios
- **Infrastructure as Code**: Terraform configurations for VM provisioning
- **Automated Updates**: Watchtower for container updates, Dependabot for dependency management

## Development Workflow

### Environment Configuration Pattern

Every service directory follows this standardized structure:
- `docker-compose.yml` - Service definition with Traefik labels
- `.env.example` - Template with ALL required environment variables
- `README.md` - Service-specific documentation and setup instructions

**Standard Workflow**:
```bash
cd docker/service-name
cp .env.example .env
# Edit .env with your specific values
docker compose up -d
```

### Deployment Patterns

#### Option 1: Portainer GitOps (Recommended)

Portainer provides automated Git-based deployments:

1. **Configure Portainer Stack**:
   - Repository URL: Your fork or main repository URL
   - Repository reference: `refs/heads/main`
   - Compose path: `docker/service-name`
   - Enable automatic updates (optional)

2. **Automatic Deployment**:
   - Portainer automatically pulls changes from Git
   - Services are redeployed when compose files change
   - Environment variables managed through Portainer UI

3. **Benefits**:
   - Centralized management for all services
   - Web UI for monitoring and logs
   - Automatic Git synchronization
   - Easy rollback capabilities

#### Option 2: Manual Deployment

For direct Docker Compose management:

```bash
cd docker/service-name
docker compose up -d
```

**Updating services**:
```bash
cd docker/service-name
git pull origin main
docker compose pull
docker compose up -d
```

### GitOps Deployment Process

1. **Configuration Changes**: Edit service configurations in respective directories
2. **Version Control**: Commit and push changes to Git repository
   ```bash
   git add .
   git commit -m "feat: add new service configuration"
   git push origin main
   ```
3. **Automated Deployment**: Portainer detects changes and redeploys (or manual `docker compose up -d`)
4. **Monitoring**: Use service logs and Traefik dashboard for validation
   ```bash
   docker logs -f service-name
   ```

### Traefik Dynamic Configuration

For services that need custom routing or external targets (non-Docker), place configuration in `docker/traefik/config/dynamic/`:

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

**Use Cases**:
- Routing to services on other hosts (non-Docker)
- Complex middleware configurations
- Advanced routing rules
- Load balancing across multiple backends

### Infrastructure Management

#### Terraform Integration

- **HyperCore provider** for VM provisioning
- **Cloud images**: Ubuntu LTS versions in `terraform/modules/cloud-images/`
- **VM templates**: Standardized configurations in `terraform/templates/`
- **Test environment**: Configurations in `terraform/test/`

#### GitHub Automation

- **Dependabot**: Auto-generated configuration via `.github/scripts/generate-dependabot.sh`
- **YAML validation**: Enforced on all commits via GitHub Actions
- **Weekly dependency updates**: Scheduled for Saturdays

#### External Dependencies

- **CloudNS**: DNS provider for SSL certificate automation (DNS-01 challenge)
- **Docker Hub/GHCR**: Container image sources
- **Let's Encrypt**: SSL certificate authority (automated via Traefik)

## Coding Standards

### Critical Conventions

1. **Environment Variables**
   - **ALWAYS** use `.env` files, never hardcode values
   - Common variables: `DOCKER_BASE_PATH`, `PUID`, `PGID`, `TZ`, `TRAEFIK_BASE_DOMAIN`
   - Sensitive data: Use descriptive placeholder names (e.g., `your_secure_password_here`)

2. **Timezone Standardization**
   - **ALWAYS** use `TZ=America/Los_Angeles` for consistency across all services
   - This ensures logs, schedules, and time-based operations are synchronized

3. **Image Version Pinning**
   - **NEVER** use `latest` tag - always pin to specific versions
   - Check source registry (Docker Hub/GHCR) for available tags before pinning
   - Verify tag format: some use `v1.2.3`, others use `1.2.3`
   - Review release notes for version-specific changes
   - Document pinned version in service's README.md

4. **Volume Mapping Standards**
   - Use `${DOCKER_BASE_PATH}/service-name` for persistent data
   - Media services use `${MEDIA_PATH}` for content storage
   - Always use environment variables for Portainer compatibility

5. **Network Configuration**
   - All services MUST connect to the `proxynet` external network
   - Services do NOT expose host ports directly
   - Traefik labels handle all routing

6. **Security Patterns**
   - Services with authentication: Use environment variables for credentials
   - GPU acceleration: Mount `/dev/dri:/dev/dri` for Intel/AMD GPUs
   - Container permissions: Always set `PUID`/`PGID` for file ownership

### Configuration Guidelines

- Use meaningful variable names that describe their purpose
- Follow existing Docker Compose patterns in each configuration file
- Add comments for complex logic or unusual configurations
- Use environment variables for ALL configurable values
- Maintain consistency with existing service patterns
- Document all required environment variables in `.env.example`

### YAML Standards

- All YAML files are validated using `.github/.yamllint` configuration
- Run `yamllint -c .github/.yamllint .` before committing
- GitHub Actions automatically validates YAML on every push

## Testing & Validation

### Automated Testing

- **YAML Validation**: GitHub Actions workflow (`yaml-lint.yml`) runs on every push
  ```bash
  yamllint -c .github/.yamllint .
  ```
- **Container Health Checks**: Built-in Docker Compose health check configurations
- **Service Validation**: Automated testing through Traefik routing verification
- **Dependabot**: Weekly dependency updates scheduled for Saturdays

### Manual Testing

1. **Service Deployment Testing**:
   ```bash
   cd docker/service-name
   docker compose up -d
   docker logs service-name  # Check for errors
   ```

2. **Network Connectivity Testing**:
   ```bash
   # Verify service is in proxynet
   docker network inspect proxynet
   
   # Check service accessibility
   curl -I https://service-name.${TRAEFIK_BASE_DOMAIN}
   ```

3. **Configuration Validation**:
   - Test environment variable substitution
   - Verify service-specific configuration
   - Check volume mounts and permissions

### Debugging Workflows

**Service Issues**:
```bash
# View service logs
docker logs service-name

# Follow logs in real-time
docker logs -f service-name

# Inspect container configuration
docker inspect service-name
```

**Traefik Routing Issues**:
- Check `${DOCKER_BASE_PATH}/traefik/logs/traefik.log`
- Access Traefik dashboard: `traefik.${TRAEFIK_BASE_DOMAIN}`
- Verify service discovery and routing rules
- Confirm service is in `proxynet` network: `docker network inspect proxynet`

**SSL Certificate Issues**:
- Verify CloudNS credentials in Traefik `.env`
- Check Traefik logs for ACME challenge errors
- Ensure DNS records are properly configured

**Common Troubleshooting Steps**:
1. Verify `proxynet` network exists: `docker network ls`
2. Check Traefik is running: `docker ps | grep traefik`
3. Verify service labels: `docker inspect service-name | grep traefik`
4. Test DNS resolution: `nslookup service-name.${TRAEFIK_BASE_DOMAIN}`

## Contributing

### Getting Started

1. **Fork the repository** and clone your fork
2. **Create a feature branch**: `git checkout -b feature/new-service`
3. **Make your changes** following the coding standards
4. **Test your changes locally**:
   - Verify service starts successfully
   - Test Traefik routing works
   - Check logs for errors
5. **Update documentation**:
   - Add/update service README.md
   - Update CHANGELOG.md with clear descriptions
   - Update main README.md if adding new service
6. **Validate YAML**: Run `yamllint -c .github/.yamllint .`
7. **Submit a pull request** with clear description of changes

### Contribution Guidelines

1. **Follow the service pattern**: Use existing services as templates
   - Copy structure from similar services
   - Maintain consistent Docker Compose format
   - Use standard Traefik labels

2. **Test locally**: Verify service starts and Traefik routing works
   ```bash
   cd docker/service-name
   docker compose up -d
   docker logs service-name
   curl -I https://service-name.${TRAEFIK_BASE_DOMAIN}
   ```

3. **Update CHANGELOG.md**: Document all changes with clear descriptions
   - Use clear, concise language
   - Group changes by type (Added, Changed, Fixed)
   - Include version/date information

4. **Validate YAML**: Ensure all files pass linting
   ```bash
   yamllint -c .github/.yamllint .
   ```

5. **Environment examples**: Always provide complete `.env.example` files
   - Document ALL required variables
   - Use descriptive placeholder values
   - Include comments explaining each variable

### Adding a New Service

When adding a new service, follow this checklist:

- [ ] Create service directory: `docker/service-name/`
- [ ] Create `docker-compose.yml` following standard pattern
- [ ] Create `.env.example` with all required variables
- [ ] Create `README.md` with service documentation
- [ ] Pin image to specific version (never use `latest`)
- [ ] Configure Traefik labels for routing
- [ ] Use `proxynet` external network
- [ ] Set `PUID`, `PGID`, and `TZ` environment variables
- [ ] Test deployment locally
- [ ] Update main README.md service list
- [ ] Update CHANGELOG.md
- [ ] Validate YAML files

### Code Examples and Patterns

Reference existing service configurations for implementation patterns:

**Traefik Routing**:
- Standard labels: See any `docker/*/docker-compose.yml`
- Custom routing: See `docker/traefik/config/dynamic/` for advanced examples

**Service Labels Pattern**:
```yaml
labels:
  - traefik.enable=true
  - traefik.http.services.service-name.loadbalancer.server.port=8080
  - traefik.http.routers.service-name.rule=Host(`service-name.${TRAEFIK_BASE_DOMAIN}`)
  - traefik.http.routers.service-name.entrypoints=websecure
  - traefik.http.routers.service-name.tls=true
  - traefik.http.routers.service-name.tls.certresolver=cloudns
```

**Environment Configuration**: Use existing `.env.example` files as templates

## Common Pitfalls

Avoid these common issues when working with this repository:

### Critical Issues

- **Missing proxynet network**: Services will fail to start without the external network
  ```bash
  # Fix: Create the network
  docker network create proxynet
  ```

- **Deploying services before Traefik**: Other services depend on Traefik for routing
  - **Solution**: Always deploy Traefik first, then other services

- **Incorrect Traefik labels**: Service won't be accessible via domain
  - Verify label syntax matches the standard pattern
  - Check container port matches `loadbalancer.server.port`
  - Ensure service name is consistent across all labels

- **Hardcoded paths**: Breaks portability and Portainer compatibility
  - **Fix**: Always use environment variables (`${DOCKER_BASE_PATH}`, `${MEDIA_PATH}`)

### Configuration Issues

- **Using `latest` tag**: Can cause unexpected breaking changes
  - **Fix**: Always pin to specific version tags

- **Missing GPU setup**: Hardware acceleration services need device mounting
  - **Fix**: Add `/dev/dri:/dev/dri` volume mount for Intel/AMD GPUs

- **Port conflicts**: Avoid binding to host ports (except Traefik and special cases like Netdata)
  - **Fix**: Let Traefik handle all routing through labels

- **Incorrect timezone**: Inconsistent times across services
  - **Fix**: Always use `TZ=America/Los_Angeles`

- **File permission issues**: Container can't write to volumes
  - **Fix**: Set correct `PUID` and `PGID` (usually `1000:1000`)

### Debugging Tips

1. **Service won't start**: Check logs immediately
   ```bash
   docker logs service-name
   ```

2. **Can't access service via domain**: Verify Traefik routing
   - Check Traefik dashboard: `traefik.${TRAEFIK_BASE_DOMAIN}`
   - Verify service is in `proxynet`: `docker network inspect proxynet`

3. **SSL certificate issues**: Check CloudNS configuration
   - Verify credentials in Traefik `.env`
   - Check DNS records are correct
   - Review Traefik logs for ACME errors

## Additional Resources

- **Service-specific documentation**: See individual service README files in `docker/*/`
- **Copilot Instructions**: [.github/copilot-instructions.md](.github/copilot-instructions.md) for detailed development guidelines
- **Changelog**: [CHANGELOG.md](CHANGELOG.md) for version history and recent changes
- **GitHub Workflows**: [.github/workflows/](.github/workflows/) for automation and CI/CD

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need Help?** Check the [Common Pitfalls](#common-pitfalls) section or review individual service documentation in the `docker/` directory.
