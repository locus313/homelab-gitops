# Kasm Workspaces

[Kasm Workspaces](https://www.kasmweb.com/) is a container streaming platform for delivering browser-based access to desktops, applications, and web services. It provides on-demand, disposable Docker containers accessible via web browser for use cases like Remote Browser Isolation (RBI), Desktop as a Service (DaaS), and secure remote access.

## Features

- **Container Desktop Infrastructure (CDI)**: Disposable containerized desktops and applications
- **Browser-Based Access**: Access desktop environments through web browser
- **Docker-in-Docker**: Runs workspaces as nested containers
- **Multi-Platform**: Supports various Linux desktop environments
- **Persistent Profiles**: Optional persistent user data across sessions
- **GPU Support**: Hardware acceleration for graphics-intensive workloads

## Prerequisites

- Docker and Docker Compose installed
- `proxynet` external network created: `docker network create proxynet`
- Sufficient disk space (Kasm stores Docker images and workspace data)

## Setup

1. **Copy environment template**:
   ```bash
   cd docker/kasm
   cp .env.example .env
   ```

2. **Configure environment variables**:
   Edit `.env` with your values:
   - `DOCKER_BASE_PATH`: Base path for service data (default: `/docker`)
   - `TRAEFIK_BASE_DOMAIN`: Your domain name
   - `KASM_PORT`: Web interface port (default: `8443`, must match internal/external)
   - `KASM_SETUP_PORT`: Initial setup wizard port (default: `3000`)
   - `DOCKER_HUB_USERNAME`: (Optional) DockerHub username for private images
   - `DOCKER_HUB_PASSWORD`: (Optional) DockerHub password for private images

3. **Initial installation**:
   ```bash
   docker compose up -d
   ```

4. **Access setup wizard**:
   - **Via Traefik** (recommended): `https://kasm-setup.yourdomain.com`
   - Or direct access: `https://your-ip:3000` (note: uses HTTPS with self-signed cert)
   - Follow the installation wizard
   - Configure admin credentials and initial settings
   - **Important**: After setup, set "Proxy Port" to `0` in default zone settings ([docs](https://www.kasmweb.com/docs/latest/how_to/reverse_proxy.html#update-zones))

5. **Access web interface**:
   - After setup completion: `https://kasm.yourdomain.com` (via Traefik)
   - Or direct access: `https://your-ip:8443`

6. **Post-Setup** (optional):
   - Remove the setup wizard Traefik labels from `docker-compose.yml` (lines with `kasm-setup`)
   - Redeploy the stack to clean up the temporary setup route

## Default Credentials

After installation, login with:
- Admin: `admin@kasm.local` (password set during setup)
- User: `user@kasm.local` (password set during setup)

## Configuration

### Traefik Integration

This service integrates with Traefik using labels. Key configuration:
- Uses HTTPS scheme (self-signed cert by default)
- Accessible via `kasm.${TRAEFIK_BASE_DOMAIN}`
- Port must match both internal and external (`KASM_PORT`)

### Reverse Proxy Setup

**Critical Post-Install Step**: After initial setup, you must configure Kasm for reverse proxy use:

1. Login as admin
2. Navigate to **Admin** → **Zones**
3. Edit the **default** zone
4. Set **Proxy Port** to `0`
5. Save changes

This tells Kasm to use the original request port rather than the internal container port.

### Persistent Profiles

To enable persistent user profiles:

1. Profiles are stored in `${DOCKER_BASE_PATH}/kasm/profiles`
2. When configuring a workspace, set **Persistent Profile Path** to:
   ```
   /profiles/{username}/
   ```
   or for specific workspace:
   ```
   /profiles/ubuntu-focal/{username}/
   ```

More info: [Kasm Persistent Profiles Documentation](https://www.kasmweb.com/docs/latest/how_to/persistent_profiles.html)

### GPU Support

For NVIDIA GPU support:

1. Install [NVIDIA Container Runtime](https://github.com/NVIDIA/nvidia-container-runtime) on host
2. Add to compose file:
   ```yaml
   environment:
     - NVIDIA_VISIBLE_DEVICES=all
   # OR
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: all
             capabilities: [gpu]
   ```

Kasm also has [native NVIDIA support](https://www.kasmweb.com/docs/latest/how_to/gpu.html) that can be configured in the admin panel.

### Gamepad Support

For gamepad passthrough, mount host devices:

```yaml
volumes:
  - /dev/input:/dev/input
  - /run/udev/data:/run/udev/data
```

See [Kasm Gamepad Documentation](https://www.kasmweb.com/docs/develop/guide/gamepad_passthrough.html) for setup instructions.

## Updates

### Updating Docker Image

```bash
docker compose pull
docker compose up -d
```

### Updating Kasm Application

**Important**: Docker image updates alone won't update the Kasm application. After updating the container:

1. Login as admin
2. Navigate to **Admin** → **Updates**
3. Follow in-app update process

## Storage

Data is stored in:
- `${DOCKER_BASE_PATH}/kasm/opt`: Docker-in-Docker storage, Kasm installation
- `${DOCKER_BASE_PATH}/kasm/profiles`: Optional persistent user profiles

**Note for Unraid users**: Due to DinD storage requirements, mount `/opt` directly to a disk:
- `mnt/disk1/appdata/kasm` or
- `/mnt/cache/appdata/kasm` (recommended with cache disk)

## Troubleshooting

### Container won't start

- Ensure `privileged: true` is set (required for Docker-in-Docker)
- Check disk space (`/opt` can grow large with workspace images)
- Review logs: `docker logs kasm`

### Can't access through Traefik

- Verify "Proxy Port" is set to `0` in zone settings
- Check Traefik dashboard for service discovery
- Confirm container is in `proxynet` network: `docker network inspect proxynet`

### Workspaces won't launch

- Ensure Docker has sufficient resources (CPU/RAM)
- Check Kasm logs in admin panel
- Verify Docker-in-Docker networking is functional

### SSL/Certificate Issues

- Kasm uses self-signed certificates by default
- Traefik handles SSL termination with Let's Encrypt
- For strict reverse proxies, disable certificate validation for backend

## Documentation

- [Kasm Official Documentation](https://www.kasmweb.com/docs/latest/)
- [LinuxServer.io Kasm Container](https://github.com/linuxserver/docker-kasm)
- [Reverse Proxy Configuration](https://www.kasmweb.com/docs/latest/how_to/reverse_proxy.html)
- [Building Custom Images](https://kasmweb.com/docs/latest/how_to/building_images.html)

## Version

- **Image Version**: `1.18.0` (LinuxServer.io)
- **Kasm Version**: Check in admin panel after deployment
- **Last Updated**: 2026-02-03
