# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Generate a random password for the ubuntu user
# Easy to type: only alphanumeric characters
resource "random_password" "ubuntu_password" {
  length  = 12
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Create VM from template with cloud-init configuration
resource "hypercore_vm" "test-vm" {
  tags        = ["test"]
  name        = "test-vm"
  description = "Test VM for development and experimentation"
  vcpu        = 4
  memory      = 4096  # MiB (4 GB)
  
  clone = {
    source_vm_uuid = data.hypercore_vms.template-vm.vms.0.uuid
    meta_data = templatefile("assets/meta-data.ubuntu-22.04.yml.tftpl", {
      name = "test-vm",
    })
    user_data = templatefile("assets/user-data.ubuntu-22.04.yml.tftpl", {
      name                = "test-vm",
      ssh_authorized_keys = "",
      ssh_import_id       = "",
      password            = random_password.ubuntu_password.result,
    })
  }
  affinity_strategy = {}
}

# Attach cloned virtual disk to the VM as OS disk
resource "hypercore_disk" "os" {
  vm_uuid                = hypercore_vm.test-vm.id
  type                   = "VIRTIO_DISK"
  size                   = 20.5 # GB
  source_virtual_disk_id = local.ubuntu_server_templates["22-04-jammy"].id
  depends_on = [ hypercore_vm.test-vm ]
}

resource "hypercore_nic" "hc3-vlan" {
  vm_uuid                = hypercore_vm.test-vm.id
  type                   = "VIRTIO"
  vlan                   = 0
}

resource "hypercore_vm_power_state" "test-vm" {
  vm_uuid = hypercore_vm.test-vm.id
  state   = "RUNNING" # available states are: SHUTOFF, RUNNING, PAUSED
  depends_on = [
    hypercore_disk.os,
    hypercore_nic.hc3-vlan,
    hypercore_vm_boot_order.test-vm-boot-order,
  ]
}

resource "hypercore_vm_boot_order" "test-vm-boot-order" {
  vm_uuid = hypercore_vm.test-vm.id
  boot_devices = [
    hypercore_disk.os.id,
    hypercore_nic.hc3-vlan.id,
  ]

  depends_on = [
    hypercore_disk.os,
    hypercore_nic.hc3-vlan,
  ]
}
