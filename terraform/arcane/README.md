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
secrets; keep secret-bearing and stateful services out of scope until their
secret handling, rotation, backup, and rollback paths are reviewed separately.

After merging the canary configuration, run these steps from this workspace:

1. Run `direnv exec . terraform plan` and confirm it only creates the canary
   global variable, with no destroys. Apply that reviewed plan.
2. In Arcane, open **Projects → arcane-pilot** and click **Redeploy** so the
   pilot loads the new global variable. The Compose file uses a harmless
   fallback until Terraform creates the variable.
3. Verify the fake canary is absent from state:

   ```bash
   direnv exec . terraform state show arcane_global_variable.pilot_secret_canary
   ```

   Confirm the output contains no `value_wo` or canary value.
4. Verify the pilot receives the
   canary without printing its value:

   ```bash
   docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' arcane-pilot \
     | grep -Fqx 'ARCANE_PILOT_SECRET_CANARY=not-a-secret-test-value'
   ```

   Confirm Arcane displays the global variable as secret and that other
   containers do not receive it automatically.

Destroying an Arcane GitOps sync removes its project, containers, and networks
but leaves volumes and files. Disabling `enable_pilot` or `enable_it_tools`
after creation therefore removes that project. Only apply this to the pilot
and explicitly migrated services; follow the migration procedure above for
Portainer ownership transfers.
