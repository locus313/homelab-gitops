#!/usr/bin/env bash
# ponytail: Plex's tag scheme (1.43.2.10687-<hash>) isn't semver, so
# Dependabot can't parse/compare it and silently skips this image.
# This script is the targeted fix — only Plex, not a general image-updater.
set -euo pipefail

COMPOSE_FILE="docker/plex/docker-compose.yml"
CURRENT_TAG=$(grep -oP 'plexinc/pms-docker:\K\S+' "$COMPOSE_FILE")

# Plex also pushes floating tags (latest, public, beta, plexpass) and
# per-arch tags; only accept pinned multi-arch releases (1.2.3.4-hash) and
# pick the highest version rather than the most recently pushed tag.
LATEST_TAG=$(curl -fsSL \
  "https://hub.docker.com/v2/repositories/plexinc/pms-docker/tags?page_size=100&ordering=last_updated" |
  python3 -c '
import json, re, sys
pat = re.compile(r"^(\d+(?:\.\d+){3})-[0-9a-f]{7,}$")
vers = []
for tag in json.load(sys.stdin)["results"]:
    m = pat.match(tag["name"])
    if m:
        vers.append((tuple(map(int, m.group(1).split("."))), tag["name"]))
if vers:
    print(max(vers)[1])
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
