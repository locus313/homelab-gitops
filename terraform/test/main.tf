# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Create VM using the reusable VM module
module "test_vm" {
  source = "../modules/vm"

  name        = "test-vm"
  description = "Test VM for development and experimentation"
  tags        = ["test"]
  
  vcpu   = 4
  memory = 4096  # MiB (4 GB)

  template_vm_uuid        = data.hypercore_vms.template-vm.vms.0.uuid
  meta_data_template_path = "assets/meta-data.ubuntu-22.04.yml.tftpl"
  user_data_template_path = "assets/user-data.ubuntu-22.04.yml.tftpl"
  
  ssh_authorized_keys = ""
  ssh_import_id       = ""
  
  disk_type              = "VIRTIO_DISK"
  disk_size              = 20.5  # GB
  source_virtual_disk_id = local.ubuntu_server_templates["22-04-jammy"].id
  
  nic_type = "VIRTIO"
  vlan     = 0
  
  affinity_strategy = {}
  power_state       = "RUNNING"
}
