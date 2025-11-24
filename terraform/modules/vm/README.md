# VM Module

Reusable Terraform module for creating VMs with HyperCore provider and cloud-init configuration.

## Features

- Clones VMs from templates with cloud-init support
- Automatic random password generation (optional)
- Configurable CPU, memory, disk, and network settings
- Boot order configuration
- Power state management

## Usage

```hcl
module "test_vm" {
  source = "../../modules/vm"

  name        = "test-vm"
  description = "Test VM for development"
  tags        = ["test", "development"]
  
  vcpu   = 4
  memory = 4096  # MiB

  template_vm_uuid = data.hypercore_vms.template_vm.vms.0.uuid
  
  meta_data_template_path = "assets/meta-data.ubuntu-22.04.yml.tftpl"
  user_data_template_path = "assets/user-data.ubuntu-22.04.yml.tftpl"
  
  ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  # ssh_import_id     = "gh:username"  # Optional: import from GitHub
  
  disk_size              = 20.5  # GB
  source_virtual_disk_id = local.ubuntu_server_templates["22-04-jammy"].id
  
  vlan = 0
  
  power_state = "RUNNING"
}

output "vm_password" {
  value     = module.test_vm.user_password
  sensitive = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| hypercore | latest |
| random | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the VM | `string` | n/a | yes |
| description | Description of the VM | `string` | `""` | no |
| tags | Tags to apply to the VM | `list(string)` | `[]` | no |
| vcpu | Number of virtual CPUs | `number` | `2` | no |
| memory | Memory allocation in MiB | `number` | `2048` | no |
| template_vm_uuid | UUID of the template VM to clone from | `string` | n/a | yes |
| meta_data_template_path | Path to cloud-init meta-data template | `string` | n/a | yes |
| user_data_template_path | Path to cloud-init user-data template | `string` | n/a | yes |
| ssh_authorized_keys | SSH authorized keys for the user | `string` | `""` | no |
| ssh_import_id | SSH import ID (e.g., gh:username) | `string` | `""` | no |
| user_password | User password (auto-generated if null) | `string` | `null` | no |
| disk_type | Type of disk | `string` | `"VIRTIO_DISK"` | no |
| disk_size | Disk size in GB | `number` | `20.5` | no |
| source_virtual_disk_id | ID of source disk to clone | `string` | n/a | yes |
| nic_type | Type of network interface | `string` | `"VIRTIO"` | no |
| vlan | VLAN ID for network interface | `number` | `0` | no |
| affinity_strategy | Affinity strategy for VM placement | `map(any)` | `{}` | no |
| power_state | Power state (SHUTOFF/RUNNING/PAUSED) | `string` | `"RUNNING"` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | UUID of the created VM |
| vm_name | Name of the VM |
| disk_id | ID of the OS disk |
| nic_id | ID of the network interface |
| user_password | Generated or provided user password (sensitive) |
| vm_tags | Tags applied to the VM |

## Example: Refactoring Existing Configuration

Before (in `main.tf`):
```hcl
resource "random_password" "ubuntu_password" {
  length  = 12
  special = false
}

resource "hypercore_vm" "test-vm" {
  name   = "test-vm"
  vcpu   = 4
  memory = 4096
  # ... many more lines
}
```

After (using module):
```hcl
module "test_vm" {
  source = "../../modules/vm"
  
  name                    = "test-vm"
  vcpu                    = 4
  memory                  = 4096
  template_vm_uuid        = data.hypercore_vms.template_vm.vms.0.uuid
  meta_data_template_path = "assets/meta-data.ubuntu-22.04.yml.tftpl"
  user_data_template_path = "assets/user-data.ubuntu-22.04.yml.tftpl"
  source_virtual_disk_id  = local.ubuntu_server_templates["22-04-jammy"].id
}
```

## Notes

- If `user_password` is not provided, a random 12-character alphanumeric password is automatically generated
- The module configures boot order to prioritize the OS disk
- Cloud-init templates must accept `name`, `ssh_authorized_keys`, `ssh_import_id`, and `password` variables
