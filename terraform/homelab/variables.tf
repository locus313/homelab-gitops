# ScaleComputing VM — Input Variables
variable "vm_name" {
  description = "Name of the VM in ScaleComputing and as the system hostname"
  type        = string
  default     = "sc-docker-01"
}

variable "vm_description" {
  description = "Human-readable description of the VM"
  type        = string
  default     = "Homelab Docker host — always-on SC VM for resilient service hosting"
}

variable "vm_tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = ["homelab", "docker", "production"]
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 6
}

variable "memory_mib" {
  description = "Memory allocation in MiB"
  type        = number
  default     = 16384 # 16 GB
}

variable "disk_size_gb" {
  description = "OS disk size in GB (holds /docker data and local service state)"
  type        = number
  default     = 100
}

variable "vlan" {
  description = "VLAN ID for the VM network interface"
  type        = number
  default     = 0
}

variable "ssh_import_id" {
  description = "SSH import ID to pull authorized keys from an external source (e.g., gh:yourusername)"
  type        = string
  default     = "gh:locus313"
}

variable "ssh_authorized_keys" {
  description = "SSH authorized keys to inject directly (used if ssh_import_id is not set)"
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "Username for the non-root admin account created on the VM (gets sudo NOPASSWD and docker group)"
  type        = string
  default     = "ubuntu"
}

variable "timezone" {
  description = "System timezone for the VM (e.g. America/Los_Angeles)"
  type        = string
  default     = "America/Los_Angeles"
}

# NFS / storage variables — used in cloud-init user-data template

variable "nas_ip" {
  description = "IP address of the NAS providing NFS exports"
  type        = string
}

variable "nas_media_export" {
  description = "NFS export path on the NAS for the media library (e.g., /volume1/media)"
  type        = string
}

variable "nas_shared_export" {
  description = "NFS export path on the NAS for shared homelab files, e.g., acme.json (e.g., /volume1/docker)"
  type        = string
}

variable "nas_backups_export" {
  description = "NFS export path on the NAS for backups (e.g., /volume1/Backups)"
  type        = string
  default     = "/volume1/Backups"
}

variable "media_mount_path" {
  description = "Local mount point for the NFS media export on the VM (should match MEDIA_PATH in service .env files)"
  type        = string
  default     = "/mnt/media"
}

variable "repo_url" {
  description = "Git URL of the homelab-gitops repository to clone onto the VM"
  type        = string
  default     = "https://github.com/locus313/homelab-gitops.git"
}

# ---------------------------------------------------------------------------
# dh01 Proxmox VM variables
# ---------------------------------------------------------------------------

variable "dh01_vm_name" {
  description = "Hostname of the Docker VM on pve01 (dh01 Proxmox node)"
  type        = string
  default     = "dh01"
}

variable "dh01_node_name" {
  description = "Proxmox node name (set during Proxmox install via answer file DH01_FQDN short part)"
  type        = string
  default     = "pve01"
}

variable "dh01_vcpu" {
  description = "vCPU cores for the dh01 VM"
  type        = number
  default     = 2
}

variable "dh01_memory_mib" {
  description = "Memory allocation in MiB for the dh01 VM"
  type        = number
  default     = 6144 # 6 GB
}

variable "dh01_disk_size_gb" {
  description = "OS disk size in GB for the dh01 VM"
  type        = number
  default     = 80
}

variable "dh01_datastore_id" {
  description = "Proxmox storage ID for the dh01 VM disk (must support disk images)"
  type        = string
  default     = "local-lvm"
}

variable "dh01_snippets_datastore_id" {
  description = "Proxmox storage ID with snippets + iso enabled (for cloud-init user-data)"
  type        = string
  default     = "local"
}

variable "dh01_node_ip" {
  description = "IP or FQDN of pve01 — used by scp to upload cloud-init snippets"
  type        = string
}
