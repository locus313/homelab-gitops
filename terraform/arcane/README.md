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
secrets. Keep secret-bearing services out of scope until their secret handling
and rotation paths are reviewed. Stateful services require a service-specific
backup, restore, and rollback rehearsal; the Ombi rehearsal validates only its
single configuration bind mount.

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
