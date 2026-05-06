# NetbootXYZ

NetbootXYZ is a way to PXE boot various operating system installers or utilities from a single tool over the network. It provides a convenient way to boot multiple ISOs and tools without physical media.

## Features

- PXE boot menu with multiple OS options
- Web-based management interface
- Custom menu creation
- Support for various Linux distributions
- Windows PE environments
- Utility and rescue tools
- Local ISO hosting
- Custom boot entries

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `TZ`: Your timezone
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `NGINX_PORT`: Internal nginx port
   - `WEB_APP_PORT`: Web application port

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Network Ports

This service uses several ports:
- **69/UDP**: TFTP server for PXE boot
- **8080**: HTTP server (mapped internally)
- **3000**: Web management interface (via Traefik)

## Access

- Web Interface: `https://netbootxyz.yourdomain.com` (if using Traefik)
- Direct Access: `http://your-server-ip:8080`

## PXE Boot Setup

To use NetbootXYZ for PXE booting:

1. Configure your DHCP server with:
   - **Option 66** (Boot Server): IP address of your NetbootXYZ server
   - **Option 67** (Boot Filename): `netboot.xyz.kpxe` (for legacy) or `netboot.xyz.efi` (for UEFI)

2. Ensure client machines are configured to boot from network

## Initial Setup

1. Access the web management interface
2. Configure local menu options
3. Upload custom ISOs to the assets directory
4. Create custom boot entries
5. Test PXE boot functionality

## Custom Assets

You can add custom ISOs and tools:
- Assets Directory: `${DOCKER_BASE_PATH}/netbootxyz/assets`

Place your custom ISOs and files here to make them available via the boot menu.

### Local Fedora Live Boot

The upstream `Live > Fedora` menu is broken for releases ≥ 41 (see
[netboot.xyz issue #1758](https://github.com/netbootxyz/netboot.xyz/issues/1758)).
A working local alternative is bundled here:

1. Stage Fedora Live kernel/initrd/squashfs into the assets directory:

   ```bash
   sudo ./scripts/setup-fedora-live.sh 44
   ```

   This downloads the latest Fedora 44 Workstation Live ISO, extracts
   `vmlinuz`, `initrd.img`, and `squashfs.img` to
   `${DOCKER_BASE_PATH}/netbootxyz/assets/fedora-44-live/`, and chowns
   them to the in-container `nbxyz` user so nginx can serve them.

2. The custom menu wires itself in automatically — no install step.
   When the container starts, `docker-compose.yml` bind-mounts:

   - [`autoexec.ipxe`](autoexec.ipxe) at
     `/config/menus/autoexec.ipxe` — forces `netboot.xyz.efi` to chain
     the bundled `menu.ipxe` over TFTP instead of fetching
     `https://boot.netboot.xyz/menu.ipxe`, so PXE works without
     outbound HTTPS / public DNS on the client network.
   - [`custom-menu/local-vars.ipxe`](custom-menu/local-vars.ipxe) at
     `/config/menus/local-vars.ipxe` — sets `${custom_url}`, which the
     upstream `menu.ipxe` reads and uses to surface a **"Custom URL Menu"**
     entry on the main menu.
   - [`custom-menu/custom.ipxe`](custom-menu/custom.ipxe) at
     `/assets/custom-menu/custom.ipxe` — the menu itself, served over
     HTTP by the netbootxyz nginx and chained when the user selects
     "Custom URL Menu".

   PXE boot a client and pick **Custom URL Menu** from the main netboot.xyz
   menu — Fedora 44 Workstation Live is the default selection.

To edit the menu, modify `custom-menu/custom.ipxe` and either restart the
container (Portainer redeploys on git push) or just re-PXE-boot the
client (the file is read fresh over HTTP every boot).

> **Why this design?** Both files are bind-mounted from the repo and live
> at paths that **upstream never ships** (`local-vars.ipxe` and
> `/assets/custom-menu/`). `MENU_VERSION` upgrades and image refreshes
> can never clobber them, and no upstream-shipped file is modified.

> **TFTP permissions:** dnsmasq inside the container runs with
> `--tftp-secure --user=nbxyz`, so files served via TFTP must be owned
> by the `nbxyz` user (uid **1000** in this image — NOT 911). Because
> Portainer's git checkout creates files as root, the
> [`custom-cont-init.d/99-chown-custom-menu`](custom-cont-init.d/99-chown-custom-menu)
> hook chowns the bind-mounted files to `nbxyz` on every container
> start. The script only touches files this stack owns and is safe
> across image / `MENU_VERSION` upgrades.

> **Why replace `menu.ipxe`?** The `netboot.xyz.efi` binary embeds its
> own boot script that ignores `chain` directives in `autoexec.ipxe` and
> never surfaces the upstream `:custom-user` label as a menu item.
> Hijacking `menu.ipxe` is the only reliable entry point.

> **TFTP permissions:** dnsmasq inside the container runs with
> `--tftp-secure --user=nbxyz`, so any file deployed under
> `${DOCKER_BASE_PATH}/netbootxyz/config/menus/` must be owned by the
> `nbxyz` user (uid **1000** in this image — NOT 911). Both helper
> scripts handle this automatically.

## Available Boot Options

NetbootXYZ provides access to:
- **Linux Distributions**: Ubuntu, CentOS, Fedora, Debian, and more
- **Utility Tools**: System rescue, hardware testing, antivirus
- **Windows**: Windows PE environments
- **Custom**: Your own uploaded ISOs and tools

## Volumes

- Config: `${DOCKER_BASE_PATH}/netbootxyz/config` - NetbootXYZ configuration
- Assets: `${DOCKER_BASE_PATH}/netbootxyz/assets` - Custom ISOs and tools

## Network

This service is configured to use the `proxynet` external network for Traefik integration, with additional port mappings for PXE functionality.

## NetbootXYZ Image

This deployment uses the official NetbootXYZ image (`ghcr.io/netbootxyz/netbootxyz:0.7.6-nbxyz18`) which provides:

- Comprehensive boot menu options
- Regular updates with new distributions
- Web-based configuration interface
- Support for custom boot entries
