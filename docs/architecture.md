# Architecture

Diagrams are Mermaid, which renders natively on github.com. Terms are defined in [GLOSSARY.md](../GLOSSARY.md); the reasoning behind each choice is in [docs/adr/](adr/) and [resilience-planning.md](resilience-planning.md).

## Hosts and infrastructure

Terraform provisions two Docker VMs. Arcane manages the migrated application
projects on dh02 and Netdata on dh01 through its remote agent. The Portainer
manager and dh01 Portainer agent are stopped and retained for rollback.

```mermaid
graph TB
    classDef tf fill:#5c4ee5,stroke:#fff,color:#fff
    classDef vm fill:#1565c0,stroke:#90caf9,color:#fff
    classDef hw fill:#4e342e,stroke:#ffcc02,color:#fff
    classDef ext fill:#1b5e20,stroke:#a5d6a7,color:#eee

    subgraph IAC["Terraform workspaces"]
        TFH["terraform/homelab<br/>VM provisioning"]:::tf
        TFP["terraform/portainer<br/>retained state and shared environment"]:::tf
        TFA["terraform/arcane<br/>Git syncs and environment"]:::tf
    end

    subgraph SC["ScaleComputing HyperCore cluster"]
        SCVM["sc_docker_vm<br/>always-on baseline<br/>Traefik, Arcane, Plex,<br/>Home Assistant, Gitea, and most services"]:::vm
    end

    subgraph PVE["pve01 (Proxmox VE, Intel N150)"]
        DHVM["dh01_docker_vm<br/>Arcane agent and Netdata"]:::vm
    end

    NAS[("NAS<br/>NFS: media, shared, backups")]:::ext

    TFH -->|hypercore provider| SCVM
    TFH -->|proxmox provider| DHVM
    TFP -.->|shared environment| TFA
    TFA -->|Arcane API| SCVM
    DHVM -->|agent connection| SCVM
    SCVM ---|NFS| NAS
```

## GitOps deploy flow

A commit to `main` reaches running containers through manager polling, with no
manual deploy step. Arcane polls Git and deploys projects locally on dh02 or
through its dh01 agent. The manager and agent are bootstrapped independently
of these Git syncs.

```mermaid
graph LR
    classDef step fill:#1565c0,stroke:#90caf9,color:#fff
    classDef ci fill:#2e7d32,stroke:#a5d6a7,color:#fff

    DEV["Commit and push"]:::step --> MAIN["GitHub main"]:::step
    MAIN --> CI["CI<br/>yamllint, terraform fmt/validate,<br/>changelog"]:::ci
    MAIN -->|polled| ARC["Arcane manager"]:::step
    TFA["terraform/arcane<br/>Git syncs, env, and secrets"]:::step -->|configures| ARC
    ARC -->|local deploy| D2["Compose projects on dh02"]:::step
    ARC -->|remote deploy| AGENT["Arcane agent on dh01"]:::step
    AGENT --> D1["Netdata project on dh01"]:::step
```

## Request path and TLS

```mermaid
sequenceDiagram
    participant C as Client
    participant D as DNS (wildcard A record)
    participant T as Traefik
    participant S as Service container
    participant N as CloudNS

    Note over T,N: Certificate issuance (DNS-01)
    T->>N: Create TXT record for wildcard cert
    N-->>T: Challenge validated
    T->>T: Store cert in acme.json (NFS)

    C->>D: service.domain
    D-->>C: sc_docker_vm IP
    C->>T: HTTPS :443
    T->>S: HTTP to internal port (proxynet)
    S-->>C: Response via Traefik
```

## Storage

`sc_docker_vm` keeps service data on its local `/docker` disk and mounts three NAS NFS exports through cloud-init.

```mermaid
graph LR
    classDef vm fill:#1565c0,stroke:#90caf9,color:#fff
    classDef store fill:#4e342e,stroke:#ffcc02,color:#fff

    SCD["sc_docker_vm<br/>local /docker<br/>(service data)"]:::vm
    NM[("NAS media export<br/>/mnt/media")]:::store
    NS[("NAS shared export<br/>/mnt/docker<br/>Traefik cloudns-acme.json")]:::store
    NB[("NAS backups export<br/>/mnt/backups")]:::store

    SCD --- NM
    SCD --- NS
    SCD --- NB
```

## Failover (planned)

Failover and replication are described as a design in [resilience-planning.md](resilience-planning.md). It is a plan and not a record of what is deployed, so it is not diagrammed here.
