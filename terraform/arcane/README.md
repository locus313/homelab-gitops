# Arcane Terraform pilot

This workspace manages only an isolated pilot on the Arcane manager's local
Docker host (dh02). It does not configure dh01 or take over Portainer stacks.
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
   but does not itself redeploy on an environment-only change. Finally, test a
   Git change through Arcane's hourly sync and confirm the existing IT Tools
   stack is unchanged.

Never put production secrets into the pilot's `environment_variables` map:
it is not documented as write-only and Terraform state may contain its values.
Arcane project environment files are also plaintext on the host. Test a
secret strategy and automatic redeployment separately before migrating
production stacks.

The provider deletes the pilot's project, containers and networks when its
sync resource is destroyed. Disabling the pilot after creation therefore
removes it. Do not use this destroy behavior for existing Portainer stacks;
their ownership transfer and rollback require a separate reviewed procedure.
