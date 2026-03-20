#!/bin/bash

# ============================================================================
# Generates .github/dependabot.yml with configuration for Docker Compose,
# Terraform, and GitHub Actions ecosystems.
# Uses glob patterns so no dynamic directory discovery is needed — new
# services under docker/ and terraform/ are covered automatically.
# ============================================================================

set -euo pipefail

readonly OUTFILE=".github/dependabot.yml"
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

cat > "$tmpfile" <<'YAML'
version: 2

updates:
  - package-ecosystem: "docker-compose"
    directories:
      - "/docker/*"
    schedule:
      interval: "daily"
    groups:
      docker-images:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"

  - package-ecosystem: "terraform"
    directories:
      - "/terraform/**"
    schedule:
      interval: "weekly"
      day: "monday"
    groups:
      terraform-providers:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"

  - package-ecosystem: "github-actions"
    directories:
      - "/"
    schedule:
      interval: "weekly"
      day: "saturday"
    groups:
      github-actions:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
YAML

if ! [[ -f "$OUTFILE" ]] || ! cmp -s "$tmpfile" "$OUTFILE"; then
  mv "$tmpfile" "$OUTFILE"
  echo "✅ Updated $OUTFILE"
else
  echo "ℹ️ No changes to $OUTFILE"
fi
