#!/usr/bin/env bash
# ponytail: Plex's tag scheme (1.43.2.10687-<hash>) isn't semver, so
# Dependabot can't parse/compare it and silently skips this image.
# This script is the targeted fix — only Plex, not a general image-updater.
set -euo pipefail

COMPOSE_FILE="docker/plex/docker-compose.yml"
CURRENT_TAG=$(grep -oP 'plexinc/pms-docker:\K\S+' "$COMPOSE_FILE")

# Docker Hub tags are sorted by last_pushed; the arch-specific and "latest"
# tags share the same digest as the real multi-arch release, so skip them.
LATEST_TAG=$(curl -fsSL \
  "https://hub.docker.com/v2/repositories/plexinc/pms-docker/tags?page_size=25&ordering=last_updated" |
  python3 -c '
import json, sys
data = json.load(sys.stdin)
for tag in data["results"]:
    name = tag["name"]
    if name != "latest" and not name.endswith(("-amd64", "-arm64", "-armhf")):
        print(name)
        break
')

if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "$CURRENT_TAG" ]]; then
  echo "Plex is up to date ($CURRENT_TAG)."
  echo "updated=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

sed -i "s|plexinc/pms-docker:${CURRENT_TAG}|plexinc/pms-docker:${LATEST_TAG}|" "$COMPOSE_FILE"

echo "Updated Plex: ${CURRENT_TAG} -> ${LATEST_TAG}"
{
  echo "updated=true"
  echo "old_tag=${CURRENT_TAG}"
  echo "new_tag=${LATEST_TAG}"
} >> "$GITHUB_OUTPUT"
