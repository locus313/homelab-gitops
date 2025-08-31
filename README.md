# Homelab GitOps

A comprehensive repository for managing self-hosted services using Docker Compose and GitOps principles. This project provides configurations for various homelab services, automation scripts, and deployment workflows to streamline your self-hosted infrastructure management.

## Technology Stack

- **Containerization**: Docker, Docker Compose
- **Reverse Proxy**: Traefik v3.4.4
- **Orchestration**: Portainer (optional)
- **Infrastructure as Code**: Terraform with HyperCore provider
- **CI/CD**: GitHub Actions
- **Configuration Management**: Environment variables, YAML configurations
- **Monitoring**: Beszel (lightweight server monitoring)
- **Development Tools**: Code-Server, IT Tools, Stirling PDF, Webtop
- **Media Services**: Plex, Ombi, HandBrake, MeTube
- **Network Boot**: iVentoy, NetbootXYZ

## Project Architecture

The project follows a GitOps approach with Docker Compose configurations for each service. Traefik serves as the central reverse proxy, providing SSL termination and dynamic routing to all services. Each service is containerized and configured through environment variables for easy customization.

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Internet      │────│   Traefik    │────│   Services      │
│                 │    │ (Reverse     │    │ - Plex          │
└─────────────────┘    │  Proxy)      │    │ - Ombi          │
                       │              │    │ - Homarr        │
                       └──────────────┘    │ - Code-Server   │
                                           │ - Webtop        │
                                           │ - Beszel        │
                                           │ - IT Tools      │
                                           └─────────────────┘
```

Services communicate through the `proxynet` external Docker network, with Traefik handling SSL certificates via Let's Encrypt and CloudNS DNS challenge.

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Git for repository management
- (Optional) Portainer for web-based stack management
- Domain name with DNS provider support (for SSL certificates)

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
   cp .env.example .env  # If available
   # Edit .env file with your specific values
   ```

3. **Deploy services**:
   ```bash
   docker compose up -d
   ```

### Initial Configuration

1. **Set up external network**:
   ```bash
   docker network create proxynet
   ```

2. **Configure DNS and SSL**:
   - Set up CloudNS credentials in Traefik environment variables
   - Configure `TRAEFIK_BASE_DOMAIN` for your domain

3. **Deploy Traefik first** (acts as the reverse proxy for other services)

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
│   ├── code-server/        # Browser-based IDE
│   ├── webtop/             # Linux desktop environment in browser
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
- **Monitoring and Dashboards**: Beszel for system monitoring, Homarr for service management
- **Development Environment**: Code-Server for browser-based development, Webtop for full Linux desktop environments
- **Desktop Access**: Webtop provides browser-accessible Linux desktops with GPU acceleration support
- **Media Stack**: Plex media server with Ombi request management and HandBrake transcoding
- **Network Boot Services**: iVentoy and NetbootXYZ for PXE boot scenarios
- **Infrastructure as Code**: Terraform configurations for VM provisioning
- **Automated Updates**: Watchtower for container updates, Dependabot for dependency management

## Development Workflow

### GitOps Deployment Process

1. **Configuration Changes**: Edit service configurations in respective directories
2. **Version Control**: Commit changes to Git repository
3. **Automated Deployment**: Portainer pulls changes and redeploys services
4. **Monitoring**: Use service logs and Traefik dashboard for validation

### Testing and Validation

- **YAML Linting**: Automated validation using `.github/.yamllint` configuration
- **GitHub Actions**: `yaml-lint.yml` workflow validates all YAML files
- **Service Health Checks**: Individual service health checks in Docker Compose files
- **Log Analysis**: Centralized logging through Docker and Traefik

### Infrastructure Management

- **Terraform Workflows**: Manage VM templates and infrastructure provisioning
- **Environment Separation**: Separate configurations for test and production environments
- **Backup Strategies**: Volume mapping for persistent data preservation

## Coding Standards

- **Environment Variables**: Use `.env` files for all configuration values
- **Naming Conventions**: Follow existing directory structure and service naming patterns
- **Docker Compose Structure**: Maintain consistent service definitions with proper networks and volumes
- **Security Practices**: Implement proper secrets management and security configurations
- **Documentation**: Include clear descriptions and comments for complex configurations
- **Relative Paths**: Use relative volume mounts where possible for Portainer compatibility

### Configuration Guidelines

- Use meaningful variable and function names
- Follow existing code style in each configuration file
- Add comments for complex logic or unusual configurations
- Use environment variables for sensitive data (e.g., `PLEX_CLAIM`, `SECRET_ENCRYPTION_KEY`)
- Maintain consistency with existing service patterns

## Testing

### Automated Testing

- **YAML Validation**: GitHub Actions workflow using yamllint
- **Container Health Checks**: Built-in Docker Compose health check configurations
- **Service Validation**: Automated testing through Traefik routing verification

### Manual Testing

- **Service Deployment**: Test individual service deployment with `docker compose up -d`
- **Network Connectivity**: Verify service accessibility through Traefik proxy
- **Configuration Validation**: Test environment variable substitution and service configuration

### Debugging Tools

- **Container Logs**: `docker logs <container-name>` for service-specific debugging
- **Traefik Dashboard**: Access at `traefik.${TRAEFIK_BASE_DOMAIN}` for routing inspection
- **Beszel Monitoring**: System-level monitoring and alerting

## Contributing

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-service`
3. Make your changes following the coding standards
4. Test your changes locally
5. Update documentation as needed
6. Submit a pull request with clear description

### Contribution Guidelines

- **Code Quality**: Follow existing patterns and conventions
- **Documentation**: Update `CHANGELOG.md` with concise descriptions of changes
- **Testing**: Ensure all tests pass and add new tests for new functionality
- **Service Addition**: Follow the established directory structure in `docker/`
- **Environment Variables**: Document all required environment variables in service `.env` files

### Code Examples

Reference existing service configurations for implementation patterns:
- **Traefik Routing**: See `docker/traefik/config/dynamic/` for routing examples
- **Service Labels**: Follow Traefik label patterns in existing `docker-compose.yml` files
- **Environment Configuration**: Use existing `.env` files as templates

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

For detailed service-specific documentation and advanced configuration options, refer to individual service directories and the [Copilot Instructions](.github/copilot-instructions.md).
