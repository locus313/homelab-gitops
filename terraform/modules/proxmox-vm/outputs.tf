output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "VM name / hostname"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "admin_password" {
  description = "Admin user password (auto-generated if not provided)"
  value       = local.password
  sensitive   = true
}
