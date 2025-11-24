# VM Module - Reusable module for creating VMs with cloud-init

# Generate a random password for the user if not provided
resource "random_password" "user_password" {
  count   = var.user_password == null ? 1 : 0
  length  = 12
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Create VM from template with cloud-init configuration
resource "hypercore_vm" "vm" {
  tags        = var.tags
  name        = var.name
  description = var.description
  vcpu        = var.vcpu
  memory      = var.memory
  
  clone = {
    source_vm_uuid = var.template_vm_uuid
    meta_data = templatefile(var.meta_data_template_path, {
      name = var.name,
    })
    user_data = templatefile(var.user_data_template_path, {
      name                = var.name,
      ssh_authorized_keys = var.ssh_authorized_keys,
      ssh_import_id       = var.ssh_import_id,
      password            = var.user_password != null ? var.user_password : random_password.user_password[0].result,
    })
  }
  affinity_strategy = var.affinity_strategy
}

# Attach cloned virtual disk to the VM as OS disk
resource "hypercore_disk" "os" {
  vm_uuid                = hypercore_vm.vm.id
  type                   = var.disk_type
  size                   = var.disk_size
  source_virtual_disk_id = var.source_virtual_disk_id
  depends_on             = [hypercore_vm.vm]
}

# Create network interface
resource "hypercore_nic" "nic" {
  vm_uuid = hypercore_vm.vm.id
  type    = var.nic_type
  vlan    = var.vlan
}

# Set boot order
resource "hypercore_vm_boot_order" "boot_order" {
  vm_uuid = hypercore_vm.vm.id
  boot_devices = [
    hypercore_disk.os.id,
    hypercore_nic.nic.id,
  ]

  depends_on = [
    hypercore_disk.os,
    hypercore_nic.nic,
  ]
}

# Power on VM
resource "hypercore_vm_power_state" "vm_power" {
  vm_uuid = hypercore_vm.vm.id
  state   = var.power_state
  depends_on = [
    hypercore_disk.os,
    hypercore_nic.nic,
    hypercore_vm_boot_order.boot_order,
  ]
}
