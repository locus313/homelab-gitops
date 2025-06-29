#!/bin/bash
# https://medium.com/@svenvanginkel/automating-dependabot-for-docker-compose-13acdff61133
set -euo pipefail

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Header
cat > "$tmpfile" <<'YAML'
version: 2
updates:
  - package-ecosystem: "docker-compose"
    directories:
YAML

# Find and sort all docker-compose.yml directories
find . -regex '.*/\(docker-\)?compose\(-[\w]+\)?\(?>\.[\w-]+\)?\.ya?ml' -print0 \
  | xargs -0 -n1 dirname \
  | sed 's|^\./||' \
  | sort \
  | while read -r dir; do
      echo "      - \"/$dir\"" >> "$tmpfile"
    done

# Append the schedule block
cat >> "$tmpfile" <<'YAML'
    schedule:
      interval: "weekly"
YAML

# Install if changed
if ! [ -f .github/dependabot.yml ] || ! cmp -s "$tmpfile" .github/dependabot.yml; then
  mv "$tmpfile" .github/dependabot.yml
  echo "✅ Updated .github/dependabot.yml!"
else
  echo "ℹ️ No changes to .github/dependabot.yml."
fi
