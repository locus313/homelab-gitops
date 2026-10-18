# Coding Standards

Rules the reviewer enforces on a diff. Mechanical rules live in CI (`.github/workflows/`) and `.pre-commit-config.yaml`; this file holds judgement calls only.

## Documentation

- Diagrams are fenced `mermaid` blocks, which render on github.com. Use no images or ASCII art for diagrams.
- Diagrams and docs describe deployed state, verified against `terraform/` and `docker/`. Mark anything planned as a plan.
- Keep the README project tree in step with the filesystem: a new or removed directory updates the tree in the same change.
- Use the terms in `GLOSSARY.md`. Record a hard-to-reverse decision as an ADR in `docs/adr/`.
