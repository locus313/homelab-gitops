# proxmox-vm module variables

variable "name" {
  description = "VM name and hostname"
  type        = string
}

variable "description" {
  description = "Human-readable description of the VM"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "node_name" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID. Omit (null) to let Proxmox auto-assign"
  type        = number
  default     = null
}

variable "vcpu" {
  description = "Number of virtual CPU cores"
  type        = number
  default     = 2
}

variable "memory_mib" {
  description = "Memory allocation in MiB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Proxmox storage ID for the VM disk and cloud-init ISO"
  type        = string
  default     = "local-lvm"
}

variable "snippets_datastore_id" {
  description = "Proxmox storage ID that has snippets enabled (for cloud-init user-data)"
  type        = string
  default     = "local"
}

variable "bridge" {
  description = "Linux bridge for the VM network interface"
  type        = string
  default     = "vmbr0"
}

variable "cloud_image_url" {
  description = "URL of the Ubuntu cloud image (.img) to download and use as the OS disk"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "user_data_template_path" {
  description = "Path to the cloud-init user-data template file (.tftpl)"
  type        = string
}

variable "template_vars" {
  description = "Variables passed to the user-data template"
  type        = map(string)
  default     = {}
}

variable "ssh_authorized_keys" {
  description = "SSH public keys to authorize for the admin user"
  type        = list(string)
  default     = []
}

variable "ssh_import_id" {
  description = "SSH import ID to pull keys from an external source (e.g., gh:username)"
  type        = string
  default     = ""
}

variable "user_password" {
  description = "Password for the admin user. If null, a random password is generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "node_ip" {
  description = "IP address or FQDN of the Proxmox node — used by scp to upload the cloud-init snippet (system SSH, compatible with Bitwarden agent)"
  type        = string
}

variable "ssh_user" {
  description = "SSH username for uploading the cloud-init snippet to the Proxmox node"
  type        = string
  default     = "root"
}
