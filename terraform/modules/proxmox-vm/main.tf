# proxmox-vm module — creates a Ubuntu cloud-init VM on a Proxmox VE node.
#
# Prerequisites on the Proxmox host:
#   - A storage with type "dir" or "nfs" that has both "snippets" AND "iso"
#     content enabled (default: "local" storage).  The snippets store holds
#     the rendered cloud-init user-data; the iso store holds the downloaded
#     cloud image.
#   - QEMU guest agent package installed inside the VM (included in the
#     cloud-init user-data template via packages: [qemu-guest-agent]).
#
# Authentication: set PROXMOX_VE_ENDPOINT, PROXMOX_VE_API_TOKEN in .envrc.

# Generate a random password for the admin user when none is provided.
resource "random_password" "user_password" {
  count   = var.user_password == null ? 1 : 0
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

locals {
  password = var.user_password != null ? var.user_password : random_password.user_password[0].result
}

# Download the Ubuntu cloud image into Proxmox storage.
# overwrite = false avoids re-downloading on every plan when the file exists.
resource "proxmox_download_file" "cloud_image" {
  content_type = "iso"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  url       = var.cloud_image_url
  file_name = "${var.name}-cloud-image.img"
  overwrite = false
}

# Render the cloud-init user-data template to a local temp file.
resource "local_file" "cloud_init_rendered" {
  filename = "/tmp/terraform-proxmox-${var.name}-user-data.yml"
  content = templatefile(var.user_data_template_path, merge(
    var.template_vars,
    {
      name                = var.name
      ssh_authorized_keys = jsonencode(var.ssh_authorized_keys)
      ssh_import_id       = var.ssh_import_id
      password            = local.password
    }
  ))
}

# Upload the rendered snippet to Proxmox via scp.
# Uses the system SSH binary (compatible with Bitwarden SSH agent),
# bypassing the provider's Go SSH library which cannot read from the agent.
resource "null_resource" "upload_cloud_init" {
  triggers = {
    content_hash = sha256(local_file.cloud_init_rendered.content)
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=accept-new '${local_file.cloud_init_rendered.filename}' '${var.ssh_user}@${var.node_ip}:/var/lib/vz/snippets/${var.name}-user-data.yml'"
  }
}

# Create the VM.
resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.name
  description = var.description
  node_name   = var.node_name
  vm_id       = var.vm_id
  tags        = var.tags

  cpu {
    cores = var.vcpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mib
  }

  # Root disk — resized to var.disk_size_gb from the cloud image.
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_download_file.cloud_image.id
    interface    = "virtio0"
    size         = var.disk_size_gb
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  # Cloud-init drive: passes user-data snippet + DHCP config to the VM.
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = "${var.snippets_datastore_id}:snippets/${var.name}-user-data.yml"
  }

  operating_system {
    type = "l26"
  }

  # QEMU guest agent — must be installed inside the VM (see user-data template).
  agent {
    enabled = true
  }

  # Prevent re-applying cloud-init after initial provision.
  lifecycle {
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }

  depends_on = [null_resource.upload_cloud_init]
}
