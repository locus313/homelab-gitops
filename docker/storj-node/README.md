# Storj Storage Node

A Storj decentralized storage node that earns STORJ tokens by sharing unused disk space and bandwidth with the network.

## Prerequisites

1. **Node Identity**: Generate your node identity before starting. Follow the [Storj Identity Setup Guide](https://docs.storj.io/node/get-started/identity) and place identity files in `${DOCKER_BASE_PATH}/storj-node/identity/`.

2. **Port Forwarding**: Port `28967` (TCP + UDP) must be forwarded from your router to the host running this container.

3. **Wallet**: An ERC-20 compatible wallet address (Ethereum or zkSync) for STORJ payouts.

## Setup

```bash
cd docker/storj-node
cp .env.example .env
# Edit .env with your values
docker compose up -d
```

## Key Environment Variables

| Variable | Description |
|---|---|
| `WALLET` | ERC-20 wallet address for STORJ payouts |
| `EMAIL` | Operator email for network notifications |
| `ADDRESS` | Public `ip-or-hostname:28967` (must be port-forwarded) |
| `STORAGE` | Max disk space to allocate (e.g. `2.0TB`) |
| `STORAGE_PATH` | Host path for node data storage |

## Ports

| Port | Protocol | Purpose |
|---|---|---|
| `28967` | TCP/UDP | Storj peer connections — must be publicly accessible |
| `14002` | TCP | Dashboard (routed via Traefik) |

## Dashboard

Access the node dashboard at `https://storj-node.${TRAEFIK_BASE_DOMAIN}`.

## Notes

- Image version: `9109fd2` (storjlabs/storagenode)
- The identity directory is required before the node can start. A new identity must be authorized by Storj before the node is eligible to receive data.
- Storage path should be on a large, reliable disk. Avoid network shares for `STORAGE_PATH`.
- Node vetting takes approximately 9 months of uptime. Avoid downtime during this period.
