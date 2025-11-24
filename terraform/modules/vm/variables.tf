# VM Module Variables

variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "description" {
  description = "Description of the VM"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory allocation in MiB"
  type        = number
  default     = 2048
}

variable "template_vm_uuid" {
  description = "UUID of the template VM to clone from"
  type        = string
}

variable "meta_data_template_path" {
  description = "Path to the cloud-init meta-data template file"
  type        = string
}

variable "user_data_template_path" {
  description = "Path to the cloud-init user-data template file"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "SSH authorized keys for the user"
  type        = string
  default     = ""
}

variable "ssh_import_id" {
  description = "SSH import ID (e.g., gh:username)"
  type        = string
  default     = ""
}

variable "user_password" {
  description = "Password for the user. If null, a random password will be generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "disk_type" {
  description = "Type of disk (VIRTIO_DISK, IDE_DISK, etc.)"
  type        = string
  default     = "VIRTIO_DISK"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20.5
}

variable "source_virtual_disk_id" {
  description = "ID of the source virtual disk to clone"
  type        = string
}

variable "nic_type" {
  description = "Type of network interface (VIRTIO, E1000, etc.)"
  type        = string
  default     = "VIRTIO"
}

variable "vlan" {
  description = "VLAN ID for the network interface"
  type        = number
  default     = 0
}

variable "affinity_strategy" {
  description = "Affinity strategy for VM placement"
  type        = map(any)
  default     = {}
}

variable "power_state" {
  description = "Power state of the VM (SHUTOFF, RUNNING, PAUSED)"
  type        = string
  default     = "RUNNING"

  validation {
    condition     = contains(["SHUTOFF", "RUNNING", "PAUSED"], var.power_state)
    error_message = "Power state must be one of: SHUTOFF, RUNNING, PAUSED"
  }
}
