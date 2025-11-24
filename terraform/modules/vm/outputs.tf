# VM Module Outputs

output "vm_id" {
  description = "UUID of the created VM"
  value       = hypercore_vm.vm.id
}

output "vm_name" {
  description = "Name of the VM"
  value       = hypercore_vm.vm.name
}

output "disk_id" {
  description = "ID of the OS disk"
  value       = hypercore_disk.os.id
}

output "nic_id" {
  description = "ID of the network interface"
  value       = hypercore_nic.nic.id
}

output "user_password" {
  description = "Generated or provided password for the user"
  value       = var.user_password != null ? var.user_password : random_password.user_password[0].result
  sensitive   = true
}

output "vm_tags" {
  description = "Tags applied to the VM"
  value       = hypercore_vm.vm.tags
}
