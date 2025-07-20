# Agents.md for Homelab GitOps

This `agents.md` file provides comprehensive guidance for AI agents working with the Homelab GitOps repository. It is designed to ensure consistency, quality, and alignment with project standards.

## Project Overview

Homelab GitOps is a repository for managing self-hosted services using Docker Compose and GitOps principles. It includes configurations for various services, automation scripts, and workflows.

## Project Structure

- `/docker`: Contains Docker Compose configurations for services.
  - `/beszel`: Lightweight server monitoring.
  - `/handbrake`: Video transcoder.
  - `/homarr`: Homelab dashboard.
  - `/iventoy`: PXE and USB boot server.
  - `/metube`: Video downloader.
  - `/netbootxyz`: Network boot server.
  - `/nginx-proxy-manager`: Reverse proxy with SSL support.
  - `/plex`: Media server.
  - `/stirling-pdf`: PDF toolkit.
  - `/traefik`: Reverse proxy and load balancer.
    - `/config/dynamic`: Dynamic routing rules and service definitions.
  - `/watchtower`: Automated container updates.
  - `/it-tools`: Collection of handy online tools for developers, self-hosted using Docker Compose.
- `/.github`: Contains GitHub Actions workflows and scripts.
  - `/workflows`: CI/CD workflows.
  - `/scripts`: Utility scripts like `generate-dependabot.sh`.
- `/LICENSE`: License file.
- `/README.md`: Main documentation file.

## Coding Conventions

- Use meaningful variable and function names.
- Follow the existing code style in each file.
- Add comments for complex logic.
- Use environment variables for sensitive data.

## Guidelines for AI Contributions

### Code Quality

- Use the latest stable versions of libraries and dependencies.
- Follow best practices for architecture and design patterns.
- Implement proper error handling and edge case management.

### Documentation

- Document all key business logic.
- Include purpose, parameters, and examples in function docs.
- Add meaningful comments for complex algorithms.

### Maintenance

- Update the `README.md` with project purpose and setup instructions.
- Update `CHANGELOG.md` with concise descriptions of changes.

### Security

- Follow security best practices.
- Avoid hardcoding sensitive information like API keys.

## Testing

- Ensure all tests pass before submitting changes.
- Write testable code with appropriate separation of concerns.

## Pull Request Guidelines

- Include a clear description of changes.
- Reference related issues.
- Ensure all tests pass.
- Keep PRs focused on a single concern.

## Changelog Requirements

- Add entries under today's date in `CHANGELOG.md`.
- Use categories: `### Added`, `### Changed`, `### Fixed`, `### Removed`.
- Keep descriptions concise and user-focused.

## Proactive Improvements

- Suggest better approaches when applicable.
- Highlight potential issues with the requested approach.
- Offer architectural improvements and optimizations.

This `agents.md` file serves as a guide for AI agents to contribute effectively to the Homelab GitOps repository while maintaining high standards of quality and consistency.
