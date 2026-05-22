# Homelab VMs — two-node Docker host setup:
#   sc_docker_vm  — always-on VM on the ScaleComputing cluster (resilient)
#   dh01_docker_vm — VM on pve01 (Proxmox on dh01, Intel N150)
#
# See docs/resilience-planning.md for the full architecture rationale.

module "sc_docker_vm" {
  source = "../modules/vm"

  name        = var.vm_name
  description = var.vm_description
  tags        = var.vm_tags

  vcpu   = var.vcpu
  memory = var.memory_mib

  template_vm_uuid        = data.hypercore_vms.template-vm.vms.0.uuid
  meta_data_template_path = "${path.module}/assets/meta-data.docker-host.yml.tftpl"
  user_data_template_path = "${path.module}/assets/user-data.docker-host.yml.tftpl"

  ssh_authorized_keys = var.ssh_authorized_keys
  ssh_import_id       = var.ssh_import_id

  disk_type              = "VIRTIO_DISK"
  disk_size              = var.disk_size_gb
  source_virtual_disk_id = local.ubuntu_server_templates["26-04-resolute"].id

  nic_type = "VIRTIO"
  vlan     = var.vlan

  power_state = "RUNNING"

  # Extra vars passed through to the cloud-init user-data template
  extra_template_vars = {
    nas_ip             = var.nas_ip
    nas_media_export   = var.nas_media_export
    nas_shared_export  = var.nas_shared_export
    nas_backups_export = var.nas_backups_export
    media_mount_path   = var.media_mount_path
    repo_url           = var.repo_url
    admin_user         = var.admin_user
    timezone           = var.timezone
  }
}

# dh01 Docker VM — lightweight Docker host on the local Intel N150 node.
# Proxmox (pve01) runs on dh01 bare metal; this VM runs Docker services.
module "dh01_docker_vm" {
  source = "../modules/proxmox-vm"

  name        = var.dh01_vm_name
  description = "Docker host VM on dh01 (pve01 Proxmox node)"
  tags        = ["homelab", "docker", "dh01"]
  node_name   = var.dh01_node_name

  vcpu         = var.dh01_vcpu
  memory_mib   = var.dh01_memory_mib
  disk_size_gb = var.dh01_disk_size_gb

  datastore_id          = var.dh01_datastore_id
  snippets_datastore_id = var.dh01_snippets_datastore_id
  node_ip               = var.dh01_node_ip

  cloud_image_url         = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
  user_data_template_path = "${path.module}/assets/user-data.dh01-vm.yml.tftpl"

  # SSH keys imported from GitHub; no inline keys needed.
  ssh_authorized_keys = []
  ssh_import_id       = var.ssh_import_id

  template_vars = {
    admin_user = var.admin_user
    timezone   = var.timezone
    repo_url   = var.repo_url
  }
}
