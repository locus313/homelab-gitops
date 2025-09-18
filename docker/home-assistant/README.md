# Home Assistant

Home Assistant is an open-source home automation platform that focuses on privacy and local control. It provides a unified interface to monitor and control smart home devices from various manufacturers.

This configuration uses the **LinuxServer.io** image which provides additional benefits including proper file permissions, regular updates, and consistent behavior with other LinuxServer.io containers in the homelab.

## Features

- **Local Control**: All processing happens locally, no cloud dependency required
- **Privacy Focused**: Your data stays in your home
- **Device Integration**: Support for thousands of devices and services
- **Automation**: Powerful automation engine with visual editor
- **Voice Control**: Built-in voice assistants and integration with Alexa/Google
- **Mobile Apps**: Native iOS and Android applications
- **Add-ons**: Extensible with community add-ons
- **Energy Management**: Monitor and optimize energy usage
- **Security**: Built-in user management and security features

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `DOCKER_BASE_PATH`: Base path for Docker volumes (e.g., `/opt/docker`)
   - `PUID` and `PGID`: User and group IDs for file permissions (typically `1000`)
   - `TZ`: Your timezone (standardized to `America/Los_Angeles`)
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://home-assistant.yourdomain.com` (if using Traefik)
- Default Port: 8123 (internal to container)

## Initial Setup

1. Access the web interface
2. Create your first user account (this will be the admin)
3. Set your location and unit system
4. Enable analytics (optional)
5. Start adding integrations for your devices

## Important Notes

### LinuxServer.io Image Benefits
This configuration uses the LinuxServer.io Home Assistant image which provides:
- **Proper File Permissions**: PUID/PGID support for consistent file ownership
- **Pinned Versions**: Uses specific version tags for stability and predictable deployments
- **Regular Updates**: Timely security updates and Home Assistant releases via Dependabot
- **Consistent Architecture**: Follows LinuxServer.io standards used by other homelab services
- **Better Documentation**: Comprehensive documentation and community support

### Privileged Mode
This configuration runs Home Assistant in privileged mode to support:
- USB device access (Zigbee/Z-Wave dongles)
- Bluetooth device discovery
- Network device discovery
- Hardware acceleration

### Device Access
If you need to access USB devices (like Zigbee/Z-Wave dongles), you may need to add device mappings:

```yaml
devices:
  - /dev/ttyUSB0:/dev/ttyUSB0  # Zigbee/Z-Wave USB dongle
  - /dev/ttyACM0:/dev/ttyACM0  # Alternative USB device path
```

### Network Discovery
Home Assistant can discover devices on your network. The container has access to the host network stack in privileged mode for this functionality.

## Common Integrations

- **Zigbee**: Use ZHA integration with compatible dongles
- **Z-Wave**: Use Z-Wave JS integration
- **MQTT**: Connect to mosquitto or other MQTT brokers
- **Philips Hue**: Automatic discovery on local network
- **Google Cast**: Chromecast and Google Home devices
- **Spotify**: Music streaming integration
- **Weather**: Various weather service integrations

## Backup

Home Assistant configuration is stored in:
- `${DOCKER_BASE_PATH}/home-assistant/config/`

Regular backups of this directory are recommended. Home Assistant also provides built-in backup functionality through the web interface.

## Updating

This service uses pinned version tags for stability. Updates are managed through:

1. **Dependabot**: Automated pull requests for new versions
2. **Manual Updates**: Update the version tag in `docker-compose.yml` and redeploy

To manually update to a newer version:

1. Edit `docker-compose.yml` and update the image tag:
   ```yaml
   image: lscr.io/linuxserver/homeassistant:2024.10.1  # Update version here
   ```

2. Pull the new image and restart:
   ```bash
   docker compose pull
   docker compose up -d
   ```

## Troubleshooting

### Container Logs
```bash
docker logs home-assistant
```

### Configuration Check
Home Assistant validates configuration on startup. Check logs for any configuration errors.

### Device Permissions
If USB devices aren't accessible, verify:
- Device is properly connected
- Device permissions on the host
- Correct device path mapping

### Network Issues
If network discovery isn't working:
- Verify privileged mode is enabled
- Check firewall settings
- Ensure multicast is enabled on your network