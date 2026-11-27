# Arcane Terraform pilot and migrations

This workspace manages the isolated pilot and explicitly enabled service
migrations on Arcane's local Docker host (dh02). It does not configure dh01.
The [community provider](https://registry.terraform.io/providers/HellsCrimson/arcane/2.0.0)
requires Terraform 1.11 or later.

## Setup

1. Bootstrap [Arcane on dh02](../../docker/arcane/README.md), and store its
   API key in Bitwarden. Make sure this change is merged to `main` before
   enabling the pilot: Arcane pulls its Compose file from that branch.
2. Copy `.envrc.example` to `.envrc`, set the Arcane API URL, and run
   `direnv allow`. It reuses `../portainer/.envrc` for the S3 backend
   credentials and base domain; update the Bitwarden item name if needed.
3. Run `direnv exec . terraform init` and
   `direnv exec . terraform plan`. Initially, only the Git repository is
   created. Review and apply the plan.
4. Set `TF_VAR_enable_pilot=true` in `.envrc`, then review another plan and
   apply it. The provider creates and starts a separate `arcane-pilot`
   project on the local manager host.
5. Verify the pilot URL and its `ARCANE_PILOT_VALUE` container environment.
   Change `pilot_value`, apply again, and redeploy the pilot in Arcane before
   checking the container: provider 2.0.0 updates the project environment
   but does not itself redeploy on an environment-only change. The pilot's
   GitOps sync enables full-directory syncing to test supporting files; follow
   the verification steps in the [pilot README](../../docker/arcane-pilot/README.md)
   after applying the Terraform change and syncing from Git. Confirm other
   Portainer-managed stacks are unchanged.

## First service migration: IT Tools

IT Tools is a low-risk first migration on dh02: its Compose stack has no
persistent mounts or secret environment values. The Portainer stack and Arcane
project use the same container name, so migrate them in order to avoid a
container-name collision. Expect a brief outage between the two applies.

After this change is merged:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.it_tools.portainer_stack.this`, then apply
   that reviewed plan. This removes the Portainer-managed container.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_it_tools=true`. From
   `terraform/arcane`, run `direnv exec . terraform plan`. Confirm it only
   creates `arcane_gitops_sync.it_tools` and does not replace or change the
   pilot; then apply.
3. Verify `https://it-tools.<your-domain>` works, the `it-tools` container is
   running on dh02, and the project is Git-managed in Arcane.

Rollback: revert this change, apply the Arcane workspace first to remove the
Arcane sync and project, then apply the Portainer workspace to recreate the
Portainer stack. IT Tools has no persistent data to migrate.

## Stateful service migration: Ombi

Ombi is prepared for migration on dh02, but remains disabled in Terraform until
the Portainer stack is removed. Its Compose file has one persistent bind mount
(`${DOCKER_BASE_PATH}/ombi/config`) and no secret environment variables.
Before preparing this change, an encrypted Zerobyte/Restic snapshot was
restored to an isolated directory and compared with the quiesced source. The
pinned `lscr.io/linuxserver/ombi:4.53.10` image started with the restored copy
mounted at `/config`, `--network none`, and no published ports. The rehearsal
used snapshot `0c1aa87f` on 2026-11-26; production Ombi remained running after
the test.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.ombi.portainer_stack.this`, then apply
   that reviewed plan.
2. Confirm Ombi has stopped and `${DOCKER_BASE_PATH}/ombi/config` remains
   intact. In
   `terraform/arcane/.envrc`, set `TF_VAR_enable_ombi=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.ombi`; apply that reviewed plan.
3. Verify Ombi is running on dh02, the `ombi` project is Git-managed in
   Arcane, and `https://ombi.<your-domain>` works with its existing data.

For rollback, disable `enable_ombi` and apply the Arcane workspace first so
Arcane removes its project and container. Then restore the Portainer module
configuration and apply the Portainer workspace. The bind-mounted data remains
at `${DOCKER_BASE_PATH}/ombi/config`; restore it from backup only if it was
changed or corrupted.

## Stateful service migration: MeTube

MeTube is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its `/state` data is stored at
`${DOCKER_BASE_PATH}/metube`; downloads are stored separately at
`${MEDIA_PATH}/Videos/converted` and are outside the `/docker` backup.

Before preparing this change, the MeTube state directory was copied while the
service was stopped, backed up in Zerobyte snapshot `f6c973d4` on 2026-11-26,
restored to an isolated directory, and compared with the source. The pinned
`ghcr.io/alexta69/metube:2026.11.14` image started with the restored state,
`--network none`, and no published ports. The test container passed its health
check and returned HTTP 200; production MeTube remained healthy. The download
directory was not included in the restore rehearsal.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.metube.portainer_stack.this`, then apply
   that reviewed plan.
2. Confirm MeTube has stopped and `${DOCKER_BASE_PATH}/metube` remains intact.
   Confirm `metube_ytdl_options` contains no credentials or cookies; Arcane
   stores project environment values in Terraform state.
   In `terraform/arcane/.envrc`, set `TF_VAR_enable_metube=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.metube`; apply that reviewed plan.
3. Verify MeTube is running on dh02, the `metube` project is Git-managed in
   Arcane, `https://metube.<your-domain>` works with its existing state, and
   `${MEDIA_PATH}/Videos/converted` is unchanged.

For rollback, disable `enable_metube` and apply the Arcane workspace first so
Arcane removes its project and container. Then restore the Portainer module
configuration and apply the Portainer workspace. The state directory remains at
`${DOCKER_BASE_PATH}/metube`; restore it from backup only if it was changed or
corrupted. The download directory remains at
`${MEDIA_PATH}/Videos/converted`.

## Stateful service migration: HandBrake

HandBrake is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its `/config` state is stored at
`${DOCKER_BASE_PATH}/handbrake`; media and backup data remain in the existing
`${MEDIA_PATH}` and `${BACKUP_PATH}` mounts and are not part of this restore
rehearsal.

Before preparing this change, the service was stopped briefly with no active
`HandBrakeCLI` process observed. Its config was copied, included in Zerobyte
snapshot `18d15177` on 2026-11-26, and restored to an isolated directory. The
restored tree matched the source except for process-specific `Activity.log.*`
and `ghb.pid.*` filenames; the other 225 entries, including contents, matched.
The pinned `ghcr.io/jlesage/handbrake:v26.09.1` image responded from the
restored config with `--network none`, no published ports, and no media or
backup mounts. Production HandBrake remained running after the rehearsal.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.handbrake.portainer_stack.this`, then
   apply that reviewed plan.
2. Confirm HandBrake has stopped and `${DOCKER_BASE_PATH}/handbrake` remains
   intact. In `terraform/arcane/.envrc`, set
   `TF_VAR_enable_handbrake=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.handbrake`; apply that reviewed plan.
3. Verify HandBrake is running on dh02, the `handbrake` project is Git-managed
   in Arcane, `https://handbrake.<your-domain>` works with its existing config,
   and the media and backup paths are unchanged.

For rollback, disable `enable_handbrake` and apply the Arcane workspace first
so Arcane removes its project and container. Then restore the Portainer module
configuration and apply the Portainer workspace. The config remains at
`${DOCKER_BASE_PATH}/handbrake`; restore it from backup only if it was changed
or corrupted.

## Stateful service migration: NetbootXYZ

NetbootXYZ is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its configuration and boot assets are stored at
`${DOCKER_BASE_PATH}/netbootxyz/config` and
`${DOCKER_BASE_PATH}/netbootxyz/assets`; together they occupy about 7.1 GB.
The host ports for TFTP (`69/udp`) and HTTP (`8080`) remain in the existing
Compose file.

Before preparing this change, the service was stopped briefly while its config
and assets were copied, then restarted and confirmed running. Zerobyte snapshot
`924cf0a0` on 2026-11-26 at 2:25 PM included the copy. Only that copy was
restored to an isolated target. Checksum-based comparison found no differences
in either directory. The pinned
`ghcr.io/netbootxyz/netbootxyz:0.7.6-nbxyz23` image responded from the restored
config and assets with `--network none` and no published ports. No PXE client
test was performed.

The custom iPXE files in the repository are not injected by Compose. The
host-managed copies under the config and assets directories remain in place
across this migration; Arcane syncs the Compose project, not those files.
Continue copying any menu changes to the host paths as documented in the
[NetbootXYZ README](../../docker/netbootxyz/README.md).

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.netbootxyz.portainer_stack.this`, then
   apply that reviewed plan.
2. Confirm NetbootXYZ has stopped and both data directories remain intact. In
   `terraform/arcane/.envrc`, set `TF_VAR_enable_netbootxyz=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.netbootxyz`; apply that reviewed plan.
3. Verify NetbootXYZ is running on dh02, the `netbootxyz` project is
   Git-managed in Arcane, the web interface works through Traefik and port
   `8080`, and TFTP remains available on UDP port `69`.

For rollback, disable `enable_netbootxyz` and apply the Arcane workspace first
so Arcane removes its project and container. Then restore the Portainer module
configuration and apply the Portainer workspace. The config and assets remain
at their existing paths; restore them from backup only if they were changed
or corrupted.

## Stateful service migration: Beszel

Beszel is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. The hub database and key are stored at
`${DOCKER_BASE_PATH}/beszel/data`; agent state is at
`${DOCKER_BASE_PATH}/beszel/agent_data`. The shared Unix socket at
`${DOCKER_BASE_PATH}/beszel/socket` is runtime IPC and is not part of the
restore.

Before preparing this change, the Beszel agent and hub were stopped briefly
while their persisted data directories were copied, then restarted and
confirmed running. Zerobyte snapshot `3846484c` on 2026-11-26 included the
copy. Both directories restored to an isolated target and matched the copy.
The pinned `ghcr.io/henrygd/beszel/beszel:0.21.2` hub started with the restored
database using `--network none`, no published ports, and returned HTTP 200 on
loopback. The agent was not started in isolation because its existing host
network, device, and Docker socket access are not needed to validate the hub
restore. Production Beszel remained running after the rehearsal.

The existing `BESZEL_PUBLIC_KEY` is a public agent-authentication key, not a
secret. Ensure `TF_VAR_beszel_public_key` is available through
`../portainer/.envrc`, which the Arcane workspace sources. This migration
preserves the agent's existing host networking, capabilities, AppArmor setting,
device access, and read-only Docker socket mount; it does not expand them.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.beszel.portainer_stack.this`, then apply
   that reviewed plan.
2. Confirm Beszel has stopped and its data directories remain intact. In
   `terraform/arcane/.envrc`, set `TF_VAR_enable_beszel=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.beszel`; apply that reviewed plan.
3. Verify both Beszel containers are running on dh02, the `beszel` project is
   Git-managed in Arcane, the agent is connected, and
   `https://beszel.<your-domain>` works with its existing data.

For rollback, disable `enable_beszel` and apply the Arcane workspace first so
Arcane removes its project and containers. Then restore the Portainer module
configuration and apply the Portainer workspace. Beszel data remains at its
existing paths; restore it from backup only if it was changed or corrupted.

## Stateful service migration: Home Assistant

Home Assistant is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its persistent state is stored in the single
`${DOCKER_BASE_PATH}/home-assistant/config` bind mount. The current Compose stack
has no PostgreSQL sidecar or secret environment values.

Before preparing this change, Home Assistant was stopped briefly while its
config was copied, then restarted and confirmed running. Zerobyte snapshot
`5b9c491a` on 2026-11-26 included the copy. The restore UI reported a failure,
but the isolated target matched the copied config with no differences. The
pinned `lscr.io/linuxserver/homeassistant:2026.11.2` image started with the
restored config, `--network none`, no published ports or host mounts, and
without privileged mode; its loopback endpoint returned HTTP 200. Production
Home Assistant remained running and returned HTTP 200 after the temporary
test artifacts were removed.

The public Home Assistant URL currently returns HTTP 400. Home Assistant logs
identify Traefik at `172.19.0.10` as an untrusted proxy. This was observed
before and after the restore rehearsal and was not changed as part of this
migration; resolve the trusted-proxy configuration and verify the public URL
before considering the service healthy.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.home_assistant.portainer_stack.this`,
   then apply that reviewed plan.
2. Confirm Home Assistant has stopped and
   `${DOCKER_BASE_PATH}/home-assistant/config` remains intact. In
   `terraform/arcane/.envrc`, set `TF_VAR_enable_home_assistant=true`, then run
   `direnv exec . terraform plan`. Confirm it only creates
   `arcane_gitops_sync.home_assistant`; apply that reviewed plan.
3. Verify Home Assistant is running on dh02, the `home-assistant` project is
   Git-managed in Arcane, and its public URL works after fixing the existing
   trusted-proxy issue.

For rollback, disable `enable_home_assistant` and apply the Arcane workspace
first so Arcane removes its project and container. Then restore the Portainer
module configuration and apply the Portainer workspace. The config remains at
`${DOCKER_BASE_PATH}/home-assistant/config`; restore it from backup only if it
was changed or corrupted.

## Stateful service migration: Netdata

Netdata is prepared for migration on dh02 and remains disabled until its dh02
Portainer stack is removed. The dh01 Netdata stack remains managed by
Portainer. Persistent data is stored in
`${DOCKER_BASE_PATH}/netdata/{config,lib,cache}`.

Before preparing this change, dh02 Netdata was stopped briefly while its
`config`, `lib`, and `cache` directories were copied, then restarted and
confirmed running with HTTP 200. Fresh Zerobyte snapshot `852e5405` on
2026-11-26 at 5:28 PM included the copy. Only that copy was restored to an
isolated target. Zerobyte first confirmed the restore, then showed a generic
failure alert; an independent tree comparison confirmed that paths,
permissions, regular-file contents, symlink targets, and special-file types
matched. The pinned `netdata/netdata:v2.12.3` image returned HTTP 200 from the
restored state with `--network none`, no claim token, no host mounts or host
PID, and no added capabilities. The test container and temporary directories
were removed, and production Netdata remained running with HTTP 200.

The existing Compose file uses host networking, host PID, `SYS_PTRACE` and
`SYS_ADMIN`, an unconfined AppArmor profile, and read-only host and Docker
socket mounts for monitoring. Arcane will preserve these existing settings;
the isolated restore test deliberately did not use them.

`NETDATA_CLAIM_TOKEN` is supplied through the secret-marked
`arcane_global_variable.value_wo` resource in environment `0` with
`inject_into_containers = false`; only Netdata's Compose file references it.
The write-only value is not stored in Terraform state. Arcane global variables
are environment-scoped rather than project-scoped, and Arcane writes the
decrypted `.env.global` file on dh02 for Compose interpolation. Any project in
that environment could reference the token. This exposure was accepted for
this migration; restrict host-side file access and rotate the token if that
access changes.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying
   `module.netdata_dh02.portainer_stack.this`, and that dh01 is unchanged.
   Apply that reviewed plan.
2. Confirm dh02 Netdata has stopped and its three data directories remain
   intact. In `terraform/arcane/.envrc`, set `TF_VAR_enable_netdata=true`;
   the existing claim token is sourced from `../portainer/.envrc`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_global_variable.netdata_claim_token[0]` and
   `arcane_gitops_sync.netdata[0]`, then apply that reviewed plan.
3. Verify Netdata is running on dh02, the `netdata` project is Git-managed in
   Arcane, and the node is connected to Netdata Cloud. Confirm dh01 remains
   unchanged.

For rollback, disable `enable_netdata` and apply the Arcane workspace first so
Arcane removes its project and container. Then restore the dh02 Netdata
Portainer module and apply the Portainer workspace. The data remains at
`${DOCKER_BASE_PATH}/netdata/{config,lib,cache}`; restore it from backup only
if it was changed or corrupted.

## Stateless service migration: Watchtower

Watchtower is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. It has no persistent data mounts, so no data
restore rehearsal is needed. Its only mount is the Docker socket, which grants
container-management access to the host. This is existing access and will be
preserved without expansion. Watchtower uses `proxynet` but has no Traefik
router.

Removing the Portainer stack briefly pauses automatic image updates but does
not stop the other service containers. The `WATCHTOWER_CLEANUP` setting
defaults to `"true"` in Terraform, matching the existing Portainer workspace.

After this change is merged, cut over in this order to avoid a container-name
collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.watchtower.portainer_stack.this`, then
   apply that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_watchtower=true`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_gitops_sync.watchtower[0]`, then apply that reviewed plan.
3. Verify Watchtower is running on dh02 as an Arcane GitOps project, with
   `WATCHTOWER_CLEANUP` set as expected and the existing Docker socket mount.

For rollback, disable `enable_watchtower` and apply the Arcane workspace first
so Arcane removes its project and container. Then restore the Watchtower
Portainer module and apply the Portainer workspace. No Watchtower application
data needs restoring.

## Stateful and secret-bearing migration: Stirling PDF

Stirling PDF is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its persistent data is in
`${DOCKER_BASE_PATH}/stirling-pdf/{data,config,logs}`; `config` contains an H2
database and an encryption key. The service was briefly stopped for a
consistent copy, then restarted and verified healthy.

Zerobyte Docker job `0zsNnr7d` created snapshot `93b0e75e` on 2026-11-26.
Only `stirling-pdf-restore-test-source-20261126` was restored to the isolated
`/docker/stirling-pdf-restore-test-target-20261126` directory. The agent log
reported 33 files restored and 0 skipped; a content comparison matched the
source. Although the UI later displayed a restore-failed dialog, the agent log
confirmed success. The pinned `ghcr.io/stirling-tools/stirling-pdf:3.4.0`
image started against the restored mounts with `--network none` and a test-only
bootstrap password. It logged that it was using the default H2 database,
completed startup, and returned HTTP 200 from `/login` and `/`, with no SQL
errors. The test container and temporary directories were removed. Production
Stirling PDF remained healthy and returned HTTP 200; no Terraform plan or apply
was run, and dh01 was untouched.

`SECURITY_INITIALLOGIN_PASSWORD` comes from the existing
`terraform/portainer/.envrc` Bitwarden-backed value and is managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. It is not stored in Terraform state, but this
is **environment-scoped, not project-scoped**: another Compose project in
environment `0` could reference the key. Arcane writes the decrypted value to
`.env.global` in its projects directory on dh02 as plaintext. Only the Stirling
PDF Compose file should reference it. This risk is accepted for this migration;
do not place the password in `arcane_gitops_sync.environment_variables`. If the
password changes later, increment `value_wo_version`.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.stirling_pdf.portainer_stack.this`, then
   apply that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_stirling_pdf=true`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_global_variable.stirling_security_initiallogin_password[0]` and
   `arcane_gitops_sync.stirling_pdf[0]`, then apply that reviewed plan.
3. Verify Stirling PDF is running on dh02 as a Git-managed Arcane project,
   its URL works with the existing account, and its three bind mounts still
   use `${DOCKER_BASE_PATH}/stirling-pdf/{data,config,logs}`.

For rollback, disable `enable_stirling_pdf` and apply the Arcane workspace
first so Arcane removes its project and global variable. Then restore the
Stirling PDF Portainer module and apply the Portainer workspace. Data remains
at `${DOCKER_BASE_PATH}/stirling-pdf/{data,config,logs}`; restore it from
backup only if it was changed or corrupted.

## Stateful and secret-bearing migration: Gitea Mirror

Gitea Mirror is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its SQLite database and application state are stored
in the single `${DOCKER_BASE_PATH}/gitea-mirror` bind mount.

The service was stopped briefly for a consistent data copy, then restarted and
confirmed healthy. Zerobyte Docker job `0zsNnr7d` created snapshot `72d6a6d4`
on 2026-11-26 at 6:41 PM. Only
`gitea-mirror-restore-test-source-20261126` was restored to the isolated
`/docker/gitea-mirror-restore-test-target-20261126` directory; a content
comparison found the restored data identical to the source. The pinned
`ghcr.io/raylabshq/gitea-mirror:v3.54.0` image started with the restored data,
`--network none`, no published ports, and a test-only Better Auth secret. Its
health endpoint reported a connected database and healthy recovery state. The
test container and temporary directories were removed. Production Gitea Mirror
remained healthy and returned HTTP 200; no Terraform plan or apply was run, and
dh01 was untouched.

`BETTER_AUTH_SECRET` comes from the existing `terraform/portainer/.envrc`
Bitwarden-backed value and is managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. It is not stored in Terraform state, but this
is **environment-scoped, not project-scoped**: another Compose project in
environment `0` could reference the key. Arcane writes the decrypted value to
`.env.global` in its projects directory on dh02 as plaintext. Only the Gitea
Mirror Compose file should reference it. This risk is accepted for this
migration; do not put the secret in
`arcane_gitops_sync.environment_variables`. Increment `value_wo_version` if
the secret changes.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.gitea_mirror.portainer_stack.this`, then
   apply that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_gitea_mirror=true`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_global_variable.gitea_mirror_better_auth_secret[0]` and
   `arcane_gitops_sync.gitea_mirror[0]`; apply that reviewed plan.
3. Verify Gitea Mirror is running on dh02 as an Arcane Git-managed project,
   the existing account works at `https://gitea-mirror.<your-domain>`, and its
   data mount remains `${DOCKER_BASE_PATH}/gitea-mirror`.

For rollback, disable `enable_gitea_mirror` and apply the Arcane workspace first
so Arcane removes its project and global variable. Restore the Gitea Mirror
Portainer module and apply the Portainer workspace. Data remains at
`${DOCKER_BASE_PATH}/gitea-mirror`; restore it from backup only if it was
changed or corrupted.

## Stateful and secret-bearing migration: Homarr

Homarr is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its application state is stored in
`${DOCKER_BASE_PATH}/homarr/appdata`. The Compose stack also has an existing
read-only Docker socket mount for container integration; this migration does
not expand that access.

Homarr was stopped briefly for a consistent copy, then restarted and returned
HTTP 307 from its root route. Zerobyte Docker job `0zsNnr7d` created snapshot
`22120e09` on 2026-11-26 at 6:59 PM. Only
`homarr-restore-test-source-20261126` was restored to the isolated
`/docker/homarr-restore-test-target-20261126` directory; a content comparison
found the restored data identical to the source. The pinned
`ghcr.io/homarr-labs/homarr:v2.13.1` image started with the restored appdata,
`--network none`, no published ports or Docker socket, and a test-only
encryption key. Its Docker healthcheck passed and the root route returned the
same HTTP 307. The test key does not verify decryption of existing integration
credentials; the production key was not exposed. The test container and
temporary directories were removed. Production Homarr remained running and
returned HTTP 307; no Terraform plan or apply was run, and dh01 was untouched.

`SECRET_ENCRYPTION_KEY` comes from the existing
`terraform/portainer/.envrc` Bitwarden-backed value and is managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. It is not stored in Terraform state, but this
is **environment-scoped, not project-scoped**: another Compose project in
environment `0` could reference the key. Arcane writes the decrypted value to
`.env.global` in its projects directory on dh02 as plaintext. Only the Homarr
Compose file should reference it. This risk is accepted for this migration; do
not put the key in `arcane_gitops_sync.environment_variables`. Preserve the
existing key because Homarr uses it to decrypt stored integration credentials;
increment `value_wo_version` if the key changes.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.homarr.portainer_stack.this`, then apply
   that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_homarr=true`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_global_variable.homarr_secret_encryption_key[0]` and
   `arcane_gitops_sync.homarr[0]`; apply that reviewed plan.
3. Verify Homarr is running on dh02 as an Arcane Git-managed project, the
   dashboard loads with its existing configuration, and the app-data mount and
   read-only Docker socket access are unchanged.

For rollback, disable `enable_homarr` and apply the Arcane workspace first so
Arcane removes its project and global variable. Restore the Homarr Portainer
module and apply the Portainer workspace. Data remains at
`${DOCKER_BASE_PATH}/homarr/appdata`; restore it from backup only if it was
changed or corrupted.

## Stateful and secret-bearing migration: Rackula

Rackula is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. Its frontend and API sidecar share the
`proxynet` network; only the frontend is routed through Traefik. Persistent
layout data is stored in `${DOCKER_BASE_PATH}/rackula/data`.

Rackula was briefly stopped for a consistent copy, then restarted and returned
healthy status from both containers and HTTP 200 from its API health endpoint.
Zerobyte Docker job `0zsNnr7d` created snapshot `f707e63f` on 2026-11-26 at
7:25 PM. Only `rackula-restore-test-source-20261126` was restored to
`/docker/rackula-restore-test-target-20261126`. Zerobyte showed a successful
restore notification followed by a generic failure alert, but `diff -qr`
confirmed the restored contents matched the source (12 KiB). The pinned
`ghcr.io/rackulalives/rackula-api:26.11.1` and
`ghcr.io/rackulalives/rackula:v26.11.1-persist` images started with the
restored data on an internal-only Docker network, with no published ports and
a test-only API token. The API health check returned `ok` and the frontend root
request succeeded. Test containers, network, and temporary directories were
removed. Production Rackula remained healthy and its HTTPS route returned
HTTP 200; no Terraform plan or apply was run, and dh01 was untouched.

`RACKULA_API_WRITE_TOKEN` and `RACKULA_LOCAL_PASSWORD` come from the existing
`terraform/portainer/.envrc` Bitwarden-backed values;
`RACKULA_AUTH_SESSION_SECRET` is sourced there when authentication is enabled.
Arcane manages the configured secrets with write-only
`arcane_global_variable.value_wo` resources in environment `0`, with container
auto-injection disabled. The API write token is managed for every Rackula
sync; the session secret is created only when authentication is enabled, and
the local password only when `RACKULA_AUTH_MODE` is `local`.
These values are not stored in Terraform state, but Arcane globals are
**environment-scoped, not project-scoped**: another Compose project in
environment `0` could reference them. Arcane writes decrypted values to
`.env.global` in its projects directory on dh02 as plaintext. Only the Rackula
Compose file should reference these secrets. This risk is accepted for this
migration; do not put secrets in `arcane_gitops_sync.environment_variables`.
Preserve the current values and increment the corresponding
`value_wo_version` if a secret changes.

After this change is merged to `main`, cut over in this order to avoid
container-name collisions:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.rackula.portainer_stack.this`, then apply
   that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_rackula=true`. Run
   `direnv exec . terraform plan` and confirm it only creates Rackula
   resources, including the GitOps sync and secret globals required by the
   configured authentication mode; apply that reviewed plan.
3. Verify both Rackula containers are healthy on dh02, the dashboard and
   existing layouts load, authentication is unchanged, and the data mount
   remains `${DOCKER_BASE_PATH}/rackula/data`.

For rollback, disable `enable_rackula` and apply the Arcane workspace first so
Arcane removes its project and global variables. Restore the Rackula Portainer
module and apply the Portainer workspace. Data remains at
`${DOCKER_BASE_PATH}/rackula/data`; restore it from backup only if it was
changed or corrupted.

## Stateful and secret-bearing migration: Gitea

Gitea is prepared for migration on dh02 and remains disabled until its Portainer
stack is removed. Gitea and PostgreSQL use separate bind mounts:
`${DOCKER_BASE_PATH}/gitea/data` and `${DOCKER_BASE_PATH}/gitea/db`.
The running data directories were 907 MiB and 202 MiB, respectively.

Both containers were briefly stopped for a consistent cold archive. The
943 MiB archive was extracted to a temporary directory, and `tar` verified the
restored files against the archive. The restored PostgreSQL 18.6 and Gitea
28.4.0 images started successfully on an internal-only Docker network, with no
published ports and a test-only database password; Gitea's root HTTP request
succeeded. The test containers, network, and temporary files were removed.
Production PostgreSQL returned healthy and Gitea's root HTTP request succeeded
after restart. This rehearsal validated the cold archive and restore, not
Zerobyte recovery. No Terraform plan or apply was run, and dh01 was untouched.

`GITEA_DB_PASSWORD` is sourced from the existing
`terraform/portainer/.envrc` Bitwarden-backed value and managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. It is not stored in Terraform state, but this
is **environment-scoped, not project-scoped**: another Compose project in
environment `0` could reference the key. Arcane writes the decrypted value to
`.env.global` in its projects directory on dh02 as plaintext. Only the Gitea
Compose file should reference it. This risk is accepted for this migration;
do not put the password in `arcane_gitops_sync.environment_variables`.
Increment `value_wo_version` if the password changes.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.gitea.portainer_stack.this`, then apply
   that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_gitea=true`. Run
   `direnv exec . terraform plan` and confirm it only creates
   `arcane_global_variable.gitea_db_password[0]` and
   `arcane_gitops_sync.gitea[0]`; apply that reviewed plan.
3. Verify Gitea and PostgreSQL are healthy on dh02, the web UI and SSH clone
   access work, and both data mounts remain under
   `${DOCKER_BASE_PATH}/gitea`.

For rollback, disable `enable_gitea` and apply the Arcane workspace first so
Arcane removes its project and global variable. Restore the Gitea Portainer
module and apply the Portainer workspace. Data remains under
`${DOCKER_BASE_PATH}/gitea`; restore it from backup only if it was changed or
corrupted.

The pilot also tests a fake `ARCANE_PILOT_SECRET_CANARY` through
`arcane_global_variable.value_wo`. The provider documents `value_wo` as
write-only, so Terraform does not store it in state or saved plans. The
variable is scoped to Arcane's local environment (`0`) and is not automatically
injected into every container; the pilot Compose file explicitly references it.
This is environment-scoped, not project-scoped: any Compose project on the
local host could reference the key. Arcane encrypts secret values in its
database, but writes the decrypted value to `.env.global` in the projects
directory for Compose interpolation. That host-side file is plaintext, so this
test uses only a fake value. Review host file access and secret rotation before
considering real credentials.

Never put production secrets into the pilot's `environment_variables` map:
its values may be stored in Terraform state. This IT Tools migration has no
secrets. Stirling PDF uses the environment-scoped global-secret pattern
documented above; keep other secret-bearing services out of scope until their
secret handling and rotation paths are reviewed. Stateful services require a
service-specific backup, restore, and rollback rehearsal; the Ombi and Stirling
PDF rehearsals validate only their own bind mounts.

This change rotates the fake canary from version 1 to version 2. After merging
it, run these steps from this workspace:

1. Run `direnv exec . terraform plan` and confirm it only updates
   `arcane_global_variable.pilot_secret_canary[0]`, with no destroys and no
   canary value in the output. Apply that reviewed plan.
2. In Arcane, open **Projects → arcane-pilot** and click **Redeploy** so the
   pilot loads the rotated value.
3. Verify the fake canary is absent from state:

   ```bash
   direnv exec . terraform state show 'arcane_global_variable.pilot_secret_canary[0]'
   ```

   Confirm `value_wo` is shown as write-only, `value_wo_version` is `2`, and
   the canary value is absent.
4. Verify the new fake value is present without printing it:

   ```bash
   docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' arcane-pilot \
     | grep -Fqx 'ARCANE_PILOT_SECRET_CANARY=not-a-secret-rotated-test-value'
   ```

   Confirm the old fake value is absent without printing container variables:

   ```bash
   if docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' arcane-pilot \
     | grep -Fqx 'ARCANE_PILOT_SECRET_CANARY=not-a-secret-test-value'; then
     echo "Old fake canary value is still present" >&2
     exit 1
   fi
   ```

   Also confirm Arcane still marks the variable as secret. Other containers
   must not receive it automatically.

## Stateful and secret-bearing migration: Hermes Agent

Hermes Agent is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. It uses one persistent bind mount at
`${DOCKER_BASE_PATH}/hermes-agent`. Its tracked `managed-config.yaml` is
provided through a Compose `config`, so the Arcane GitOps sync enables
`sync_directory = true` to include it.

Before preparing this change, Hermes was stopped briefly for a consistent copy
and restarted. Zerobyte Docker job `0zsNnr7d` created snapshot `1f173c68` on
2026-11-26 at 8:17 PM. Only
`hermes-agent-restore-test-source-20261126` was restored to
`${DOCKER_BASE_PATH}/hermes-agent-restore-test-target-20261126`. The restore
matched all 2,164 regular files, 674 directories, and 9 symlinks; the cold
source also contained 9 Unix sockets, which were not present in the restore.
Zerobyte's Activity recorded success despite a generic failure alert. The
pinned `nousresearch/hermes-agent:v0.23.3` image started with the restored
state and read-only managed config on `--network none`, with no published
ports and test-only Discord credentials. The dashboard returned HTTP 200.
The test container and temporary directories were removed, and production
Hermes remained running. No Terraform plan or apply was run, and dh01 was
untouched.

`DISCORD_BOT_TOKEN` and `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` are sourced from
the existing `terraform/portainer/.envrc` values and managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. They are not stored in Terraform state, but
Arcane global variables are **environment-scoped, not project-scoped**:
another Compose project in environment `0` could reference them. Arcane writes
the decrypted values to `.env.global` in its projects directory on dh02 as
plaintext. Only the Hermes Compose file should reference these keys. Do not put
the secrets in `arcane_gitops_sync.environment_variables`; preserve the current
values and increment `value_wo_version` if either secret changes.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.hermes_agent.portainer_stack.this`, then
   apply that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_hermes_agent=true`. Run
   `direnv exec . terraform plan` and confirm it only creates the two Hermes
   secret globals and `arcane_gitops_sync.hermes_agent`; apply that reviewed
   plan.
3. Verify Hermes is healthy on dh02, the dashboard and Discord gateway work,
   authentication is unchanged, and the managed config and persistent state
   are present.

For rollback, disable `enable_hermes_agent` and apply the Arcane workspace first
so Arcane removes its project and global variables. Restore the Hermes Agent
Portainer module and `hermes_agent_fs_path` local, then apply the Portainer
workspace. Data remains at `${DOCKER_BASE_PATH}/hermes-agent`; restore it from
backup only if it was changed or corrupted.

## Stateful and secret-bearing migration: Mail Archiver

Mail Archiver is prepared for migration on dh02 and remains disabled until its
Portainer stack is removed. The app and PostgreSQL sidecar use persistent bind
mounts under `${DOCKER_BASE_PATH}/mail-archiver`; the database is approximately
8.9 GiB. The pinned images are `s1t5/mailarchiver:2611.2` and `postgres:18.6`.

Before preparing this change, both containers were stopped briefly for a
consistent copy and then restarted. PostgreSQL returned healthy and the Mail
Archiver login route returned HTTP 200. Zerobyte Docker job `0zsNnr7d` created
snapshot `108d076d` on 2026-11-26 at 8:42 PM. Only
`mail-archiver-restore-test-source-20261126` was selected for restore to
`/docker/mail-archiver-restore-test-target-20261126`. Zerobyte showed conflicting
completion and failure alerts, but a full recursive comparison found no
differences between the stopped-source copy and restored data (8.9 GiB).

The pinned `postgres:18.6` and `s1t5/mailarchiver:2611.2` images started against
the restored database on an internal-only network, with no published ports and
test-only credentials. PostgreSQL accepted the app connection and the login
route returned HTTP 200. The test containers, network, and temporary
directories were removed. Production PostgreSQL remained healthy and its login
route returned HTTP 200. No Terraform plan or apply was run, and dh01 was
untouched.

`MAIL_ARCHIVER_ADMIN_PASSWORD` and `MAIL_ARCHIVER_DB_PASSWORD` are sourced from
the existing `terraform/portainer/.envrc` values and managed with
`arcane_global_variable.value_wo`, scoped to Arcane environment `0`, with
`inject_into_containers = false`. They are not stored in Terraform state, but
Arcane global variables are **environment-scoped, not project-scoped**: another
Compose project in environment `0` could reference them. Arcane writes the
decrypted values to `.env.global` in its projects directory on dh02 as
plaintext. Only the Mail Archiver Compose file should reference these keys. Do
not put the secrets in `arcane_gitops_sync.environment_variables`; preserve the
current values and increment `value_wo_version` if either secret changes.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.mail_archiver.portainer_stack.this`, then
   apply that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_mail_archiver=true`. Run
   `direnv exec . terraform plan` and confirm it only creates the two Mail
   Archiver secret globals and `arcane_gitops_sync.mail_archiver`; apply that
   reviewed plan.
3. Verify both containers are healthy on dh02, the login route works, existing
   accounts and archived messages are present, and both data mounts remain
   under `${DOCKER_BASE_PATH}/mail-archiver`.

For rollback, disable `enable_mail_archiver` and apply the Arcane workspace
first so Arcane removes its project and global variables. Restore the
Mail Archiver Portainer module and apply the Portainer workspace. Data remains
under `${DOCKER_BASE_PATH}/mail-archiver`; restore it from backup only if it was
changed or corrupted.

## Host-network media migration: Plex

Plex is prepared for migration on dh02 and remains disabled until its Portainer
stack is removed. It uses host networking and stores configuration under
`${DOCKER_BASE_PATH}/plex/config` (48 GiB); transcode data is separate and
disposable. Terraform supplies the persistent paths, media path, and ownership
IDs. The existing Plex configuration is reused.

On 2026-11-26, Plex was stopped briefly for a cold config copy to
`/mnt/backups/plex-restore-rehearsal-20261126/source`, then restarted healthy.
This was a file-copy rehearsal, not a Zerobyte snapshot: the available
Zerobyte browser session redirected to login. A restore copy was made at
`/mnt/backups/plex-restore-rehearsal-20261126/restored`; both copies measured
48 GiB. Recursive comparison reported a pre-existing dangling codec-cache
symlink (`iHD_drv_video.so`); its link target matched in both copies and is
also absent in the original config. The restored test copy was normalized to
the original config's `1000:1000` ownership. It started with the pinned
`plexinc/pms-docker:1.43.5.11079-b3b13e506` image under `--network none`, with
no published ports. Its health check passed and `/identity` returned HTTP 200.
The test container and temporary directories were removed. Production Plex
remained healthy. No Terraform plan or apply was run, and dh01 was untouched.

`PLEX_CLAIM` is sourced from the existing `terraform/portainer/.envrc` value
and managed with `arcane_global_variable.value_wo`, scoped to Arcane
environment `0`, with `inject_into_containers = false`. It is not stored in
Terraform state, but Arcane global variables are **environment-scoped, not
project-scoped**: another Compose project in environment `0` could reference
this key. Arcane writes the decrypted value to `.env.global` in its projects
directory on dh02 as plaintext. Only the Plex Compose file should reference
this key. Do not put it in `arcane_gitops_sync.environment_variables`.

After this change is merged to `main`, cut over in this order to avoid a
container-name collision:

1. In `terraform/portainer`, run `direnv exec . terraform plan`. Confirm the
   only change is destroying `module.plex.portainer_stack.this`, then apply
   that reviewed plan.
2. In `terraform/arcane/.envrc`, set `TF_VAR_enable_plex=true`. Run
   `direnv exec . terraform plan` and confirm it only creates the Plex claim
   global and `arcane_gitops_sync.plex`; apply that reviewed plan.
3. Verify Plex is healthy on dh02, clients can reach it over the existing
   host-network address, and configuration and media libraries are present.

For rollback, disable `enable_plex` and apply the Arcane workspace first so
Arcane removes its project and global variable. Restore the Plex Portainer
module and apply the Portainer workspace. Data remains under
`${DOCKER_BASE_PATH}/plex`; restore it from backup only if it was changed or
corrupted.

## Gates before further service migrations

IT Tools has no persistent mounts or secrets, so its successful transfer does
not validate stateful or secret-bearing migrations. Ombi's isolated restore
rehearsal validates its own configuration backup path, not other services.

- **Secrets:** Keep `arcane_gitops_sync.environment_variables` non-secret;
  provider values may be stored in Terraform state. `value_wo` is write-only,
  but Arcane global variables are environment-scoped, not project-scoped. Keep
  `inject_into_containers = false` and reference a secret only in the intended
  Compose file; any project in that environment could still reference it.
  `pre_deploy_env_wo` is only for a pre-deploy script, not the deployed
  Compose project's environment. Do not migrate real secrets until the fake
  rotation test above passes and this environment-wide scope is accepted.
- **Data:** Record every bind mount and named volume. Back up application data
  separately from Arcane's project files and verify a restore before cutover.
  The provider's GitOps `mode = "backup"` backs up project files to Git; it
  does not back up bind-mounted data. Never use the public repository to store
  secret `.env` files.
- **Cutover and rollback:** Review the Portainer and Arcane plans separately.
  Remove the Portainer owner before creating the same-named Arcane project.
  Roll back by removing the Arcane sync first, then restoring the Portainer
  stack; restore application data from backup only if it was changed or
  corrupted.

Destroying an Arcane GitOps sync removes its project, containers, and networks
but leaves volumes and files. Disabling `enable_pilot`, `enable_it_tools`, or
`enable_ombi` after creation therefore removes that project. Only apply this to
the pilot and explicitly migrated services; follow each migration procedure
above for Portainer ownership transfers.
