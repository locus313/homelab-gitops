# Homelab SC VM — always-on Docker host on the ScaleComputing cluster
#
# This provisions a single Ubuntu VM to run the majority of homelab services.
# It is intended to stay running even when dh01 has a hardware failure.
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
    nas_ip            = var.nas_ip
    nas_media_export  = var.nas_media_export
    nas_shared_export = var.nas_shared_export
    media_mount_path  = var.media_mount_path
    repo_url          = var.repo_url
    admin_user        = var.admin_user
    timezone          = var.timezone
  }
}
