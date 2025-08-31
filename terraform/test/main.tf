# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Create virtual disk from Ubuntu 22.04 cloud image
resource "hypercore_virtual_disk" "ubuntu-2204" {
  name       = "ubuntu-2204-server-cloudimg-amd64.img"
  source_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

# Create VM from template with cloud-init configuration
resource "hypercore_vm" "test-vm" {
  tags        = ["test"]
  name        = "test-vm"
  description = "Test VM for development and experimentation"
  vcpu        = 4
  memory      = 4096 # MiB
  
  clone = {
    source_vm_uuid = data.hypercore_vms.template-vm.vms.0.uuid
    meta_data = templatefile("assets/meta-data.ubuntu-22.04.yml.tftpl", {
      name = "test-vm",
    })
    user_data = templatefile("assets/user-data.ubuntu-22.04.yml.tftpl", {
      name                = "test-vm",
      ssh_authorized_keys = "",
      ssh_import_id       = "",
    })
  }

  # snapshot_schedule_uuid = hypercore_vm_snapshot_schedule.demo1.id
  # TODO: update "" -> null

  # Pin VM to the first node in cluster for performance
  # If preferred_node fails, run VM on any other node
  affinity_strategy = {
    strict_affinity     = true
    preferred_node_uuid = data.hypercore_nodes.node_1.nodes.0.uuid
    backup_node_uuid    = null
    # backup_node_uuid = data.hypercore_nodes.node_2.id
  }
}

# Attach cloned virtual disk to the VM as OS disk
resource "hypercore_disk" "os" {
  vm_uuid                = hypercore_vm.test-vm.id
  type                   = "VIRTIO_DISK"
  size                   = 20.5 # GB
  source_virtual_disk_id = hypercore_virtual_disk.ubuntu-2204.id
}

# resource "hypercore_disk" "iso" {
#   vm_uuid                = hypercore_vm.demo_vm.id
#   type                   = "IDE_CDROM"
#   iso_uuid               = hypercore_iso.alpine_virt.id
#   // TODO size, should be computed
#   size     = 0.066060288
# }

resource "hypercore_nic" "hc3-vlan" {
  vm_uuid                = hypercore_vm.test-vm.id
  type                   = "VIRTIO"
  vlan                   = 12
}

# import {
#   to = hypercore_vm_power_state.demo_vm
#   id = hypercore_vm.demo_vm.id
# }

resource "hypercore_vm_power_state" "test-vm" {
  vm_uuid = hypercore_vm.test-vm.id
  state   = "RUNNING" # available states are: SHUTOFF, RUNNING, PAUSED
  depends_on = [
    hypercore_disk.os,
    #hypercore_disk.iso,
    hypercore_nic.hc3-vlan,
    hypercore_vm_boot_order.test-vm-boot-order,
  ]
}

resource "hypercore_vm_boot_order" "test-vm-boot-order" {
  vm_uuid = hypercore_vm.test-vm.id
  boot_devices = [
    hypercore_disk.os.id,
    #hypercore_disk.iso.id,
    hypercore_nic.hc3-vlan.id,
  ]

  depends_on = [
    hypercore_disk.os,
    #hypercore_disk.iso,
    hypercore_nic.hc3-vlan,
  ]
}
