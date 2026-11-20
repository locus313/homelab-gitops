#!/usr/bin/env bash
# ponytail: Plex's tag scheme (1.43.2.10687-<hash>) isn't semver, so
# Dependabot can't parse/compare it and silently skips this image.
# This script is the targeted fix — only Plex, not a general image-updater.
set -euo pipefail

COMPOSE_FILE="docker/plex/docker-compose.yml"
CURRENT_TAG=$(grep -oP 'plexinc/pms-docker:\K\S+' "$COMPOSE_FILE")

PUBLIC_TAG=$(curl -fsSL \
  "https://plex.tv/api/downloads/5.json?channel=public&build=linux-x86_64&distro=debian" |
  python3 -c '
import json, re, sys
tag = json.load(sys.stdin)["computer"]["Linux"]["version"]
if not re.fullmatch(r"\d+(?:\.\d+){3}-[0-9a-f]{7,}", tag):
    raise SystemExit(f"Unexpected public Plex image tag: {tag}")
print(tag)
')

if ! curl -fsS \
  "https://hub.docker.com/v2/repositories/plexinc/pms-docker/tags/${PUBLIC_TAG}" \
  >/dev/null; then
  echo "Plex public release ${PUBLIC_TAG} is not available on Docker Hub." >&2
  exit 1
fi

if [[ "$PUBLIC_TAG" == "$CURRENT_TAG" ]]; then
  echo "Plex is up to date ($CURRENT_TAG)."
  echo "updated=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

sed -i "s|plexinc/pms-docker:${CURRENT_TAG}|plexinc/pms-docker:${PUBLIC_TAG}|" "$COMPOSE_FILE"

echo "Updated Plex: ${CURRENT_TAG} -> ${PUBLIC_TAG}"
{
  echo "updated=true"
  echo "old_tag=${CURRENT_TAG}"
  echo "new_tag=${PUBLIC_TAG}"
} >> "$GITHUB_OUTPUT"
