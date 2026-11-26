# Arcane pilot

This disposable copy of IT Tools tests Arcane Git sync and Terraform-managed
environment variables without touching the existing IT Tools stack. It uses
`ghcr.io/corentinth/it-tools:2024.10.22-7ca5933` and is reachable at
`https://arcane-pilot.<your-domain>`.

Deploy it on dh02 through the [Arcane Terraform workspace](../../terraform/arcane/README.md).
The `ARCANE_PILOT_VALUE` variable is a non-secret marker for verifying
environment propagation; do not put real secrets in it.

The `homelab.arcane-pilot.git-sync-test` container label provides a marker to
verify that a Git change was deployed by Arcane's scheduled sync.

`ARCANE_PILOT_SECRET_CANARY` is a fake value for testing Arcane's write-only
global variable support. Terraform scopes it to dh02's local environment and
disables automatic injection into containers; this project explicitly passes
it to the pilot container. Before Terraform creates it, Compose uses a harmless
fallback so an early Git sync does not fail. Arcane encrypts the value in its
database but materializes it in plaintext in the global `.env.global` file
under its projects directory. Do not use a real credential for this test.
