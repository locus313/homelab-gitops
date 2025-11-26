# VM Cluster Module

This module creates a cluster of multiple virtual machines using the base VM module. It's designed for deploying consistent sets of VMs with automatic naming, tagging, and resource allocation.

## Features

- **Automated Naming**: VMs are automatically named `<cluster_name>-node-N`
- **Cluster Tagging**: Each VM gets cluster and node-specific tags
- **Flexible Node Count**: Deploy 1-10 nodes (default: 3)
- **Consistent Configuration**: All nodes share the same specs (CPU, memory, disk)
- **Individual Passwords**: Each node gets a unique random password if not specified

## Usage

### Basic 3-Node Cluster

```hcl
module "k8s_cluster" {
  source = "../modules/vm-cluster"

  cluster_name        = "k8s-prod"
  cluster_description = "Production Kubernetes cluster"
  node_count          = 3
  
  vcpu   = 4
  memory = 8192  # MiB (8 GB)

  template_vm_uuid        = data.hypercore_vms.template-vm.vms.0.uuid
  meta_data_template_path = "assets/meta-data.ubuntu-22.04.yml.tftpl"
  user_data_template_path = "assets/user-data.ubuntu-22.04.yml.tftpl"
  
  ssh_import_id = "gh:yourusername"
  
  disk_size              = 40  # GB
  source_virtual_disk_id = local.ubuntu_server_templates["22-04-jammy"].id
  
  tags = ["kubernetes", "production"]
}
```

This creates:
- `k8s-prod-node-1` with tags: `kubernetes`, `production`, `cluster:k8s-prod`, `node:1`
- `k8s-prod-node-2` with tags: `kubernetes`, `production`, `cluster:k8s-prod`, `node:2`
- `k8s-prod-node-3` with tags: `kubernetes`, `production`, `cluster:k8s-prod`, `node:3`

### Custom Node Count

```hcl
module "docker_swarm" {
  source = "../modules/vm-cluster"

  cluster_name = "swarm"
  node_count   = 5
  
  vcpu   = 2
  memory = 4096

  # ... other required variables
}
```

### With Affinity Strategy

```hcl
module "ha_cluster" {
  source = "../modules/vm-cluster"

  cluster_name = "ha-services"
  node_count   = 3
  
  affinity_strategy = {
    strict_affinity = "AVOID"  # Spread nodes across hosts
  }

  # ... other required variables
}
```

## Outputs

### Basic Information
- `cluster_name` - Name of the cluster
- `node_count` - Number of nodes deployed
- `vm_names` - List of all VM names
- `vm_ids` - List of all VM UUIDs

### Detailed Node Information
- `nodes` - Map of node names to their complete configuration
- `disk_ids` - List of disk IDs for all nodes
- `nic_ids` - List of NIC IDs for all nodes
- `user_passwords` - Map of node names to passwords (sensitive)

### Accessing Node Information

```hcl
# Get all VM IDs
output "cluster_vms" {
  value = module.k8s_cluster.vm_ids
}

# Get specific node info
output "master_node" {
  value = module.k8s_cluster.nodes["k8s-prod-node-1"]
}

# Get all passwords (mark as sensitive in your output)
output "node_passwords" {
  value     = module.k8s_cluster.user_passwords
  sensitive = true
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Base name for the cluster | string | - | yes |
| cluster_description | Description of the cluster | string | "VM Cluster" | no |
| node_count | Number of nodes (1-10) | number | 3 | no |
| vcpu | Virtual CPUs per node | number | 2 | no |
| memory | Memory in MiB per node | number | 2048 | no |
| disk_size | Disk size in GB per node | number | 20.5 | no |
| template_vm_uuid | Template VM UUID | string | - | yes |
| source_virtual_disk_id | Source virtual disk ID | string | - | yes |
| meta_data_template_path | Cloud-init meta-data template path | string | - | yes |
| user_data_template_path | Cloud-init user-data template path | string | - | yes |
| ssh_authorized_keys | SSH authorized keys | string | "" | no |
| ssh_import_id | SSH import ID (e.g., gh:username) | string | "" | no |
| user_password | User password (random if null) | string | null | no |
| tags | Additional tags for VMs | list(string) | [] | no |
| vlan | VLAN ID | number | 0 | no |
| affinity_strategy | VM placement affinity strategy | map(any) | {} | no |
| power_state | Power state (RUNNING/SHUTOFF/PAUSED) | string | "RUNNING" | no |

## Common Use Cases

### Kubernetes Cluster
```hcl
module "k8s" {
  source = "../modules/vm-cluster"
  
  cluster_name = "k8s"
  node_count   = 3
  vcpu         = 4
  memory       = 8192
  disk_size    = 50
  tags         = ["kubernetes"]
}
```

### Docker Swarm
```hcl
module "swarm" {
  source = "../modules/vm-cluster"
  
  cluster_name = "docker-swarm"
  node_count   = 5
  vcpu         = 2
  memory       = 4096
  tags         = ["docker", "swarm"]
}
```

### Database Cluster
```hcl
module "postgres_cluster" {
  source = "../modules/vm-cluster"
  
  cluster_name = "postgres-ha"
  node_count   = 3
  vcpu         = 8
  memory       = 16384
  disk_size    = 100
  tags         = ["database", "postgresql"]
}
```

## Notes

- Each node automatically gets unique cluster and node tags
- If `user_password` is not set, each node gets a unique random password
- Node numbering starts at 1 (not 0)
- All nodes share the same resource specifications
- For heterogeneous clusters, use the base VM module directly
