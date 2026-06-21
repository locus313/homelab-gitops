## Description

<!-- What does this PR do? Why? -->

## Changes

<!-- List the files changed and what was changed in each. -->

- `docker/<service>/docker-compose.yml` —
- `docker/<service>/.env.example` —
- `docker/<service>/README.md` —

## How to Test

<!-- Steps to verify the change works correctly. -->

```bash
cd docker/<service>
cp .env.example .env
# edit .env
docker compose up -d
docker logs <service>
```

## Checklist

- [ ] Image version is pinned (no `latest` tag)
- [ ] `.env.example` lists every `${VAR}` in the compose file
- [ ] `README.md` documents the access URL and any setup steps
- [ ] Traefik labels use `${TRAEFIK_BASE_DOMAIN}` (not a hardcoded domain)
- [ ] Volume paths use `${DOCKER_BASE_PATH}/<service-name>`
- [ ] `TZ` is set to `America/Los_Angeles`
- [ ] YAML lint passes: `yamllint -c .github/.yamllint .`
- [ ] Commit message follows Conventional Commits: `feat(docker/<name>): ...`
