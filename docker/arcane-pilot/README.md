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
