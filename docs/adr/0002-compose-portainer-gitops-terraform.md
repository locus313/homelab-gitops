# 2. Docker Compose deployed by Portainer GitOps, defined in Terraform

Status: accepted

## Context

Services must be reproducible and redeploy on commit, with no Kubernetes.

## Decision

Each `docker/<service>/` directory is a Docker Compose stack. Portainer syncs it from this repo. The `terraform/portainer` workspace declares each stack, its env, and its secrets through the `portainer-stack` module. Portainer itself is bootstrapped manually to avoid a chicken-and-egg dependency.

## Consequences

- A merge to `main` redeploys changed stacks.
- A new service needs a compose file, `.env.example`, README, and a Terraform module call.
- Agents cannot run `terraform plan` or `apply` because secrets come from Bitwarden through direnv.
