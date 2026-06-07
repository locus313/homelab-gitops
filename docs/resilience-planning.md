# Homelab Resilience Planning

## Background

`dh01` (Intel N150) was the primary host running all services via Portainer GitOps. A hardware failure
took everything offline. Goal: restructure so a dh01 hardware failure results in at most 20–45 minutes
of downtime rather than several days.

**Constraints:**
- No Kubernetes — Docker Compose only
- No strict high availability required
- ScaleComputing HCI cluster available for hosting Ubuntu VMs
- dh01 hardware can run Proxmox but ScaleComputing does not support external hypervisors
- dh01 has an Intel N150 with iGPU exposed via `/dev/dri` — only Beszel Agent actively uses it; Plex/HandBrake moved to SC VM (CPU), others not deployed

---

## Hardware Overview

| Host | Type | Notes |
|------|------|-------|
| `dh01` | Physical server | Intel N150, runs **Proxmox VE 8.4-1** (`pve01`); hosts `dh01` Docker VM (Ubuntu 26.04, 2 vCPU / 6 GB / 80 GB) |
| `dh01` Docker VM | VM on pve01 | Ubuntu 26.04 Resolute, Docker 29.5.2, provisioned via Terraform (`terraform/homelab/`) |
| ScaleComputing cluster | HCI cluster | Runs own hypervisor, hosts Ubuntu VMs, does NOT support GPU passthrough |
| NAS | NAS | Already hosts media (`MEDIA_PATH`), runs Storj Node |

---

## Services Using `/dev/dri` (Intel iGPU)

These services require dh01's physical hardware and cannot use hardware acceleration on a ScaleComputing VM:

| Service | Usage |
|---------|-------|
| Plex | Hardware transcoding (Intel Quick Sync) — moving to SC VM, iGPU not required |
| HandBrake | Video transcoding — moving to SC VM, CPU transcoding sufficient |
| Open-WebUI | GPU inference acceleration — not actively deployed (N150 performance insufficient) |
| Beszel Agent | GPU stats monitoring |
| Kasm | GPU-accelerated remote desktop — not actively deployed (performance insufficient) |
| Webtop | GPU-accelerated remote desktop — not actively deployed (performance insufficient) |

**Note on Plex clients:** Apple TV, iPhone, iPad, macOS, and Linux Plex clients all support direct
play for the vast majority of content. Software transcoding on a VM is an acceptable fallback.
HandBrake CPU transcoding on a VM is similarly acceptable given infrequent use.

---

## Options Considered

### Option 1: Bare Metal dh01 + ScaleComputing Warm Standby VM

- dh01: reinstall Ubuntu, Docker + Portainer, deploy all services (same as before)
- SC VM: runs Tier 1 services only (Traefik + Home Assistant + Plex) as a warm standby
- Zerobyte backs up critical configs from dh01 to NAS nightly

**Recovery:** Update DNS → ~1–2 hours  
**Complexity:** Low  
**Tradeoff:** Manual failover, SC VM config may be stale, two places to maintain Tier 1 config

### Option 2: ScaleComputing VM Always-On, dh01 for Non-Critical Services *(Selected)*

- SC VM runs permanently with all services in standby (containers stopped or running)
- Data kept in sync via Syncthing (Send Only from dh01 → Receive Only on SC VM)
- NFS from NAS for media and Traefik certs only
- When dh01 fails: start containers on SC VM + DNS change

**Recovery:** ~20–45 minutes  
**Complexity:** Medium  
**Tradeoff:** Only Beszel Agent remains dh01-only due to iGPU dependency; Webtop, Kasm, and Open-WebUI are not actively deployed

### Option 3: Proxmox on dh01 + VM Backups to NAS

- Install Proxmox on dh01, run services inside VMs
- Proxmox Backup Server pushes VM backups to NAS
- On failure: restore VM backup to ScaleComputing

**Recovery:** 1–4 hours  
**Complexity:** Medium-High  
**Tradeoff:** Proxmox VM format is not directly importable into ScaleComputing — requires manual
disk conversion steps. Ruled out due to complexity of restore path.

### Option 4: Docker Swarm 2-Node

- dh01 + SC VM form a 2-node Swarm
- NFS from NAS provides shared volumes
- Automated failover when dh01 node is lost

**Recovery:** Near-zero  
**Complexity:** High  
**Tradeoff:** Docker Swarm is less actively developed; NFS as shared volume store introduces its
own single point of failure; stateful services (SQLite databases) need careful volume management.
Not justified given "no strict HA" requirement.

---

## Selected Architecture: Option 2

### Storage Layout

```
NAS (NFS exports)                           VM mount point
├── <nas_media_export>        →   /mnt/media             read-mostly media (unchanged)
└── <nas_shared_export>       →   /mnt/docker/
    └── traefik/
        └── cloudns-acme.json     Traefik Let's Encrypt certs (plain JSON, not SQLite)
                                  Must be pre-created: touch + chmod 600

dh01 local /docker
  Syncthing Send Only  ──────────────────────────────────────────────→  sc-docker-01 local /docker
                                                                          Syncthing Receive Only
  ├── plex/                       SQLite — auto-recovers on startup
  ├── homeassistant/              YAML configs only (recorder moved to PostgreSQL)
  ├── homeassistant-db/           PostgreSQL data dir
  ├── gitea/                      SQLite — auto-recovers on startup
  ├── portainer/                  Portainer data (bind mount, not named volume)
  ├── beszel/                     SQLite — metrics loss on failover is acceptable
  ├── syncthing/                  Syncthing config itself
  └── <all other services>
```

`/mnt/docker/` and `${MEDIA_PATH}` are NFS-mounted on `sc-docker-01` via fstab entries
provisioned by cloud-init (using `nfsvers=4,hard,intr,_netdev` options). dh01 mounts the same
NFS exports if needed, but its local `/docker` is the authoritative copy for Syncthing.

### Synology DSM 7.3.2 — NFS Export Configuration

Two shared folders are required on the NAS. The media share likely already exists; the `docker`
share is used for `cloudns-acme.json` (and already exists on this NAS).

**Step 1 — Enable NFSv4**

Control Panel → File Services → NFS → tick **Enable NFS service** and set maximum NFS protocol
to **NFSv4.1**. Set the NFSv4 domain to match your domain or leave blank (defaults to
`localdomain`). Click Apply.

**Step 2 — Verify the `docker` shared folder exists**

Control Panel → Shared Folder — confirm `docker` is listed. This folder maps to
`<nas_shared_export>` in the Terraform variables: `/volume1/docker`.

**Step 3 — Set NFS permissions on each shared folder**

Repeat for both shared folders (media and docker):

Control Panel → Shared Folder → select folder → Edit → NFS Permissions → Create

| Setting | Media share | docker share |
|---------|-------------|-----------------|
| Hostname or IP | SC VM IP (and dh01 IP if needed) | SC VM IP |
| Privilege | Read/Write | Read/Write |
| Squash | No mapping | No mapping |
| Security | sys | sys |
| Enable asynchronous | Yes | Yes |
| Allow connections from non-privileged ports | Yes | Yes |
| Allow users to access mounted subfolders | Yes | Yes |

**"No mapping" squash** (i.e. `no_root_squash`) is required so that the root user inside Docker
containers can create files and set the `600` permission on `cloudns-acme.json`.

**Step 4 — Pre-create `cloudns-acme.json` on the NAS**

SSH into the NAS (or use File Station to create the subfolder and an empty file), then fix the
permission:

```bash
mkdir -p /volume1/docker/traefik
touch /volume1/docker/traefik/cloudns-acme.json
chmod 600 /volume1/docker/traefik/cloudns-acme.json
```

Traefik will refuse to start if `acme.json` has permissions wider than `600`.

**Terraform variable values for this setup:**

```hcl
nas_ip             = "<NAS IP>"
nas_media_export   = "/volume1/<media-share-name>"
nas_shared_export  = "/volume1/docker"
```

### Why NFS Only for `cloudns-acme.json` and Media

Running `/docker` wholesale over NFS or SMB causes SQLite corruption. SQLite uses POSIX advisory
file locking; NFS v4 implements these locks better than SMB/CIFS but is still not reliable under
write load. Services with significant SQLite write load:

| Service | SQLite | Write Frequency |
|---------|--------|-----------------|
| Home Assistant recorder | Yes | Very high (every state change) |
| Plex library DB | Yes | High during scans |
| Gitea | Yes | Moderate |
| Beszel metrics | Yes | Moderate |

`cloudns-acme.json` (Traefik certs) is plain JSON written infrequently — safe on NFS. Keeping it
on NFS means the SC VM Traefik instance has current SSL certs immediately on failover without a
restore step, avoiding Let's Encrypt rate limit issues.

### Why Syncthing Over rsync or Litestream

| Tool | Data sync | SQLite safe | Failover step | Complexity |
|------|-----------|-------------|---------------|------------|
| Syncthing | Near real-time | Mostly (auto-recovers) | None — already synced | Low |
| rsync cron | Periodic | Mostly (auto-recovers) | None — already synced | Low |
| Litestream | SQLite streaming | Consistent | `restore` per DB | Medium |

Syncthing is preferred because:
- One container per host, no per-service configuration
- Web UI for setup and monitoring
- Send Only / Receive Only pattern prevents accidental reverse sync from SC VM to dh01
- No restore step on failover — SC VM already has current data
- Litestream is a valid upgrade path if SQLite corruption becomes an issue in practice

### Why PostgreSQL for Home Assistant

Home Assistant's recorder writes every state change from every sensor and device — potentially
thousands of writes per minute. This makes its SQLite database the highest-risk file for
corruption during a Syncthing copy. Moving the recorder to PostgreSQL:

- Eliminates the highest-write SQLite database from the sync concern
- HA's YAML config files (automations, scripts, integrations) sync perfectly as plain files
- Recommended by Home Assistant for any non-minimal installation

---

## Service Split: SC VM vs dh01-Only

### SC VM (always running, synced data, starts on failover)

| Service | Notes |
|---------|-------|
| Traefik | Primary ingress; `acme.json` from NFS |
| Home Assistant | PostgreSQL recorder; YAML configs from Syncthing |
| Plex | Permanent home; no `/dev/dri`, direct play covers clients |
| Open-WebUI + Ollama | Not actively deployed — N150 iGPU performance insufficient; skip unless hardware improves |
| Gitea / Gitea-mirror | |
| Homarr | |
| Portainer | Manages SC VM stacks |
| Beszel Hub | |
| Zerobyte | Backup agent |
| IT-Tools, Stirling-PDF | |
| MeTube | |
| HandBrake | CPU transcoding (iGPU not required) |
| NetbootXYZ | |
| iVentoy | Not currently deployed — conflicts with NetbootXYZ on port 69/udp (TFTP) |
| Watchtower | |
| Rackula | |
| Code-Server | Dev environment; accessed via Tailscale serve (no Traefik required) |

### dh01 Docker VM (runs when dh01/pve01 is available)

The `dh01` Docker VM on Proxmox (`pve01`) is a second Docker host. Services not requiring hardware
access run here as a complement to the SC VM.

| Service | Notes |
|---------|-------|
| Beszel Agent | GPU stats via `/dev/dri` passthrough (when configured); monitors dh01 VM metrics |
| Netdata | dh01 system monitoring |

**Not actively deployed (tested, performance insufficient on N150):** Open-WebUI, Ollama, Webtop, Kasm

**Note:** GPU passthrough (`/dev/dri`) from the N150 iGPU to the Proxmox VM requires PCIe passthrough
configuration in Proxmox. Not yet configured — Beszel Agent currently runs without GPU stats.

---

## Traefik Configuration per Host

### SC VM — Primary Traefik Instance

The SC VM runs the **only** Traefik instance in normal operation. All `*.domain.com` DNS records
point to the SC VM IP. dh01-only services (Beszel Agent, Netdata) do not need
Traefik — they are accessed via Tailscale, internal agent connections, or direct ports.

**DNS:**
```
*.yourdomain.com  A  <SC VM IP>
```

**`acme.json` on NFS:**

The Traefik cert store must be on NFS so SSL certs survive a failover and are immediately
available when starting Traefik on any host. Update `docker/traefik/docker-compose.yml` to
replace the local cert bind mount with the NFS path:

```yaml
volumes:
  # Remove or comment out the local cert path:
  # - ${DOCKER_BASE_PATH}/traefik/certs:/var/traefik/certs/:rw
  # Add the NFS-mounted acme.json (single file, not a directory):
  - /mnt/docker/traefik/cloudns-acme.json:/var/traefik/certs/cloudns-acme.json:rw
```

The `acme.json` file must be pre-created on the NAS with permissions `600` before Traefik first
starts, otherwise Let's Encrypt will reject it:
```bash
touch /mnt/docker/traefik/cloudns-acme.json
chmod 600 /mnt/docker/traefik/cloudns-acme.json
```

**Dynamic config — Portainer routing:**

Portainer uses HTTPS internally (self-signed cert on port 9443) so it cannot use standard
Traefik container labels. A dynamic config file is required. The existing `docker/traefik/config/dynamic/dh01.yaml` routed `dh01.domain.com` → Portainer on
dh01 — this has been removed; it is replaced by `portainer.yaml` routing `portainer.domain.com`
→ SC VM's Portainer:

```yaml
# docker/traefik/config/dynamic/portainer.yaml
http:
  routers:
    portainer:
      entryPoints:
        - websecure
      rule: 'Host(`portainer.{{ env "TRAEFIK_BASE_DOMAIN" }}`)'
      service: portainer-svc
      tls:
        certResolver: cloudns
  services:
    portainer-svc:
      loadBalancer:
        servers:
          - url: "https://portainer:9443"
```

The existing `traefik.yaml` static config (`serversTransport.insecureSkipVerify: true`) already
handles the self-signed cert on the Portainer backend — no additional `serversTransport` block is
needed.

All other SC VM services use standard Traefik container labels and are discovered automatically
via the Docker provider.

**Environment variables required in Portainer stack config:**

| Variable | Description |
|----------|-------------|
| `CLOUDNS_SUB_AUTH_ID` | CloudNS sub-auth ID for DNS challenge |
| `CLOUDNS_AUTH_PASSWORD` | CloudNS auth password |
| `TRAEFIK_BASE_DOMAIN` | Base domain (e.g. `yourdomain.com`) |
| `NAS_IP` | NAS IP used in dynamic config templates |
| `DOCKER_BASE_PATH` | Base path for log volume (e.g. `/docker`) |
| `TZ` | Timezone |
| `LEGO_PROPAGATION_TIMEOUT` | DNS propagation timeout in seconds (default: `600`) |

### dh01 — No Traefik Required

dh01 runs only non-critical services that do not need reverse proxy routing:

| Service | Access method |
|---------|--------------|
| Beszel Agent | Outbound connection to Beszel Hub on SC VM — no inbound routing needed |
| Netdata | Direct port `:19999` via host network — LAN access only |

dh01 should **not** run a Traefik instance. Running a second Traefik on dh01 with the same
wildcard DNS would cause routing conflicts. If direct HTTPS access to any dh01 service is ever
needed in future, use a dedicated `dh01.*` subdomain with a separate DNS A record pointing to
dh01's IP and a separate Traefik instance scoped to that subdomain.

---

## Failover Procedure

When dh01 becomes unavailable:

1. SSH to SC VM (or use ScaleComputing management console)
2. Verify NFS mounts are active: `mount | grep nfs`
3. `docker network create proxynet` (if not already exists — do once during initial setup)
4. Start stacks via Portainer GitOps redeploy, or manually:
   ```bash
   cd /path/to/homelab-gitops/docker/<service>
   docker compose up -d
   ```
5. Update DNS A record to point to SC VM IP
6. Traefik picks up SSL certs from NFS-mounted `acme.json` immediately

**Estimated time: 20–45 minutes**

---

## Implementation Tasks

### Terraform — SC VM Provisioning

The existing `terraform/modules/vm` module targets the ScaleComputing HyperCore provider and is
ready to use. A new Terraform workspace is needed for the homelab SC VM.

- [x] Create `terraform/homelab/` workspace mirroring `terraform/test/` structure
- [x] Add `main.tf` invoking the `vm` module (single VM, not cluster) with appropriate sizing
      (suggested: 4–8 vCPU, 16 GB RAM, 100 GB disk)
- [x] Create `terraform/homelab/assets/user-data.docker-host.yml.tftpl` cloud-init template
      (see cloud-init tasks below for required content)
- [x] Create `terraform/homelab/assets/meta-data.docker-host.yml.tftpl` (hostname: `sc-docker-01`)
- [x] Add `terraform/homelab/providers.tf`, `backend.tf`, `variables.tf`, `outputs.tf`
- [x] Apply `terraform/homelab/` — VM dh02 provisioned

### Terraform — Portainer Stacks (IaC for disaster recovery)

All Portainer-managed stacks are defined as `portainer_stack` Terraform resources using the
[Portainer provider v1.29](https://registry.terraform.io/providers/portainer/portainer/latest/docs).
This enables full stack recreation from a single `terraform apply` after bootstrapping Portainer.

**Two-phase apply workflow:**
1. `terraform/homelab/` → provisions the VM, cloud-init bootstraps Docker + Portainer
2. Generate a Portainer API key: Account → Access tokens → Add token
3. `terraform/portainer/` → creates all stacks as GitOps (repository method) resources

All stacks use `method = "repository"` pointing at this repo with `update_interval = "1h"` for
automatic GitOps polling. Traefik uses `support_relative_path = true` with `filesystem_path`
pointing to the cloned repo on the host to support `./config:/etc/traefik:ro` bind mounts.

- [x] Create `terraform/portainer/providers.tf` — portainer provider `~> 1.29`
- [x] Create `terraform/portainer/backend.tf` — same S3-compatible backend, key `portainer/terraform.tfstate`
- [x] Create `terraform/portainer/variables.tf` — portainer connection, common vars, per-service secrets
- [x] Create `terraform/portainer/main.tf` — `portainer_stack` resources for all SC VM services:
      traefik, home-assistant, plex, ombi, gitea, gitea-mirror, homarr, beszel, zerobyte,
      it-tools, stirling-pdf, metube, handbrake, netbootxyz, rackula, watchtower, code-server
      (iventoy excluded — conflicts with netbootxyz on port 69/udp)
- [x] Create `terraform/portainer/.envrc.example` — documents all `TF_VAR_*` and backend credentials
- [x] Apply `terraform/portainer/` — create all stacks via Portainer API
      (initial deploy: traefik, home-assistant, plex, gitea, gitea-mirror, homarr, beszel,
      zerobyte, it-tools, stirling-pdf, metube, handbrake, netbootxyz, rackula, watchtower)
- [x] Re-apply `terraform/portainer/` — provision ombi stack and update netbootxyz resource
      (`support_relative_path = true` + file bind mount removal requires terraform state update)

### cloud-init — SC VM Bootstrap

The cloud-init user-data template should fully configure the VM on first boot with no manual steps:

- [x] Install Docker Engine + Docker Compose plugin (via Docker's apt repo)
- [x] Install NFS client: `nfs-common`
- [x] Create `/docker` directory and mount NFS: add fstab entries for
      `<NAS_IP>:/media` → `/mnt/media` and `<NAS_IP>:/docker` → `/mnt/docker`
- [x] Create `proxynet`: `docker network create proxynet` (via `runcmd`)
- [x] Clone homelab-gitops repo to a known path (e.g., `/opt/homelab-gitops`)
- [x] Create non-root admin user (`admin_user` variable, default `ubuntu`): sudo NOPASSWD,
      docker group, SSH keys from `ssh_import_id`
- [x] Disable root SSH login: `PermitRootLogin no` via `/etc/ssh/sshd_config.d/99-homelab.conf`
- [x] Set system timezone via cloud-init `timezone` key (`timezone` variable, default `America/Los_Angeles`)
- [x] Enable unattended updates: `20auto-upgrades` + `51homelab-unattended-upgrades`
      configs written via `write_files`; all updates applied, auto-reboot at 03:00 if required
- [x] Force key-only SSH: `PasswordAuthentication no` in sshd drop-in
- [x] Docker log rotation: `/etc/docker/daemon.json` with `json-file` max 10 MB × 3 files
- [x] sysctl tuning: `vm.max_map_count=262144`, `vm.swappiness=10` via `/etc/sysctl.d/99-homelab.conf`
- [x] 4 GB swapfile: created, enabled, and added to `/etc/fstab` via `runcmd`
- [x] Install and enable Portainer via Docker Compose from the cloned repo

### Proxmox VE — dh01 Bare Metal Install via PXE

dh01 now runs **Proxmox VE 8.4-1** installed unattended via PXE boot through the netbootxyz
instance on dh02. The SC VM's NetbootXYZ serves the Proxmox installer kernel, initrd, and full
ISO image; an answer file drives unattended configuration.

- [x] Add `docker/netbootxyz/scripts/setup-proxmox.sh` — downloads Proxmox VE ISO, extracts
      `linux26` + `initrd.magic`, copies full ISO to assets dir (`proxmox-8/proxmox.iso`)
- [x] Add `docker/netbootxyz/assets/pve01-proxmox/answer.toml.tpl` — unattended Proxmox install
      answer file (kebab-case keys for PVE 8.4+: `root-password-hashed`, `disk-list`)
- [x] Add `docker/netbootxyz/custom-menu/HOSTNAME-pve01.ipxe` — per-host iPXE override that loads
      `linux26` + `initrd.magic` + full ISO as second initrd (`/proxmox.iso` in initramfs)
- [x] Successfully PXE-booted and installed Proxmox VE 8.4-1 on dh01 (`pve01`, `<pve01 IP>`)
- [x] Rename `HOSTNAME-pve01.ipxe` → `HOSTNAME-pve01.ipxe.done` to prevent re-install on next PXE boot

### Terraform — dh01 Proxmox VM Provisioning

- [x] Create `terraform/modules/proxmox-vm/` — reusable module for Ubuntu cloud-init VMs on
      Proxmox VE using `bpg/proxmox` provider (>= 0.73)
      - `proxmox_download_file` downloads Ubuntu cloud image into Proxmox storage
      - `local_file` + `null_resource` upload cloud-init snippet via `scp` (system SSH binary,
        bypasses provider's Go SSH library — required for Bitwarden SSH agent compatibility)
      - `proxmox_virtual_environment_vm` creates the VM with cloud-init drive
- [x] Add `module "dh01_docker_vm"` to `terraform/homelab/main.tf` — 2 vCPU / 6 GB / 80 GB,
      Ubuntu 26.04 Resolute, `local-lvm` datastore, node `pve01`
- [x] Add bpg/proxmox, hashicorp/null, hashicorp/local to `terraform/homelab/providers.tf`
- [x] Create `terraform/homelab/assets/user-data.dh01-vm.yml.tftpl` — cloud-init template:
      Docker Engine, proxynet, repo clone, admin user, SSH hardening, sysctl tuning
- [x] Apply `terraform/homelab/` — dh01 Docker VM provisioned; cloud-init verified complete
      (Docker 29.5.2, `proxynet` network, `/opt/homelab-gitops` repo cloned)

### cloud-init / Ansible — dh01 Post-Install (superseded by Proxmox approach above)

Original plan was Ubuntu autoinstall. Kept here for reference in case bare-metal Ubuntu is
eeded again:

- [x] Author `docker/netbootxyz/assets/dh01-autoinstall/user-data` (Ubuntu 26.04 autoinstall
      format) served by the NetbootXYZ nginx from the assets directory
- [x] Add `docker/netbootxyz/scripts/setup-ubuntu-autoinstall.sh` — downloads Ubuntu 26.04 live
      server ISO, extracts `casper/vmlinuz` + `casper/initrd`
- [x] Add a NetbootXYZ custom menu entry for dh01 autoinstall in
      `docker/netbootxyz/custom-menu/custom.ipxe`
- [ ] Alternatively: Ansible playbook `ansible/docker-host.yml` applicable to both dh01 and the
      SC VM post-cloud-init, covering Docker install, NFS mounts, proxynet, repo clone

### Docker Compose — Service Configuration Changes

All changes go into the existing repo and are deployed via Portainer GitOps:

- [ ] Add `docker/syncthing/docker-compose.yml` — new stack for both hosts
- [ ] Add `docker/syncthing/.env.example`
- [ ] Add PostgreSQL sidecar service to `docker/home-assistant/docker-compose.yml`
- [ ] Add `docker/home-assistant/.env.example` entries for `HA_DB_USER`, `HA_DB_PASSWORD`
- [ ] Update `docker/traefik/docker-compose.yml` to bind-mount `acme.json` from
      `/mnt/docker/traefik/cloudns-acme.json` instead of local path
- [x] Add `docker/traefik/config/dynamic/portainer.yaml` with Portainer routing (see Traefik section above)
- [ ] Pre-create `acme.json` on NAS with correct permissions: `touch` + `chmod 600`
- [x] Remove `devices: /dev/dri` from `docker/plex/docker-compose.yml`
- [x] Remove `devices: /dev/dri` from `docker/handbrake/docker-compose.yml`
- [x] Fix MeTube permissions: use `UID`/`GID` env vars (not `PUID`/`PGID`); add `STATE_DIR`/`TEMP_DIR`
      pointing to local volume so state files don't require NFS write access
- [x] Fix MeTube `OUTPUT_TEMPLATE` to prepend `YouTube.com - ` to downloaded filenames
- [x] Fix netbootxyz Portainer deploy: remove file bind mounts (runc bug); custom iPXE files
      (`autoexec.ipxe`, `local-vars.ipxe`, `custom.ipxe`) managed directly in persistent config volume
- [ ] Populate `/docker/netbootxyz/config/menus/local-vars.ipxe` on dh02 (currently 0 bytes);
      correct content: `#!ipxe` + `set custom_url http://${next-server}:8080/custom-menu`
- [x] Add `docker/ombi/docker-compose.yml` Portainer stack resource to `terraform/portainer/main.tf`

### NAS Configuration — Manual

NFS export configuration depends on the NAS OS (TrueNAS, Synology, etc.) and cannot easily be
expressed as IaC without a provider for that specific platform:

- [x] Add NFS export for `/media` (already exported as `/volume1/Media` to `<LAN subnet>`)
- [x] Add NFS export for `docker` share (already exported as `/volume1/docker` to `<LAN subnet>`)
- [x] `no_root_squash` confirmed on both exports — Traefik root can write through NFS
- [x] Add `everyone::allow` ACL to `/volume1/Media` on Synology (DSM) so NFS-mounted media
      is readable/writable by non-root UIDs (required for Plex and MeTube)
- [ ] Restrict both exports to dh01 and SC VM IPs only (currently open to /24 subnet — acceptable for homelab)
- [x] Pre-create `/volume1/docker/traefik/cloudns-acme.json` with `chmod 600` (owned by `<nas-admin-user>:<nas-group>`;
      `no_root_squash` on NFS export allows Traefik root to write through it)

### Portainer & Syncthing — Post-Deploy Configuration

These require UI interaction after services are running:

- [ ] In Portainer on SC VM: add dh01 as a second environment (Agent or Edge Agent)
      so both hosts are managed from the SC VM Portainer instance
- [ ] In Syncthing on dh01: add SC VM as a device (exchange device IDs via web UI)
- [ ] Configure `/docker` folder as Send Only on dh01, Receive Only on SC VM
- [ ] Exclude Syncthing's own config directory from sync to avoid conflicts:
      add `/docker/syncthing` to the ignore list
- [ ] Enable Portainer scheduled backups to NAS: Settings → Backup Portainer → schedule
- [ ] Configure Home Assistant `configuration.yaml` recorder to use PostgreSQL

### Validation

- [ ] Verify Syncthing sync is active and SC VM `/docker` matches dh01
- [ ] Verify NFS mounts survive reboot on both hosts
- [ ] Test failover: with dh01 running, start all stacks on SC VM using a test subdomain,
      verify services resolve and function, then stop SC VM stacks
- [ ] Confirm Plex clients reconnect after a simulated server IP change (DNS update test)
- [ ] Document SC VM IP and the DNS change procedure in a location accessible without dh01
      (e.g., NAS, password manager, or printed)

---

## Notes on Stack Environment Variables

### Primary approach: `terraform/portainer/` IaC

All stack environment variables are stored as `TF_VAR_*` entries in `terraform/portainer/.envrc`
(not tracked by git — secret values stay local). Terraform passes them to the Portainer API when
creating or updating stacks. The Terraform state (stored in Vultr S3) records that the stacks exist
but does **not** store the secret values — those must always come from `.envrc`.

**Disaster recovery workflow with Terraform:**
1. Provision new VM via `terraform/homelab/`
2. Bootstrap Portainer manually (or via cloud-init)
3. Generate a Portainer API key
4. Set `TF_VAR_portainer_api_key` and all other vars in `.envrc`
5. Run `terraform apply` in `terraform/portainer/` — all stacks are recreated via GitOps

### Secondary approach: Portainer built-in backup

Portainer's **Settings → Backup Portainer** exports a portable snapshot of all stacks, environment
variables, endpoints, and users. Schedule this to run periodically and save to the NAS.

On failover: deploy fresh Portainer, restore the backup file, all stacks and secrets are immediately
available. Then `terraform import` each stack if you want Terraform to re-own them.

The BoltDB at `${DOCKER_BASE_PATH}/portainer` is synced to the SC VM by Syncthing (when configured),
providing a near-real-time copy. The exported backup serves as a clean known-good snapshot.

Some environment variable values may need to differ between dh01 and SC VM (e.g., host-specific
IPs or paths). Keep a note of those differences in `.envrc` alongside the Portainer backup on the NAS.
