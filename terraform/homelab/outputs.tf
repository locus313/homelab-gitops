output "vm_id" {
  description = "UUID of the SC Docker VM in ScaleComputing"
  value       = module.sc_docker_vm.vm_id
}

output "vm_name" {
  description = "Name of the SC Docker VM"
  value       = module.sc_docker_vm.vm_name
}

output "vm_password" {
  description = "Login password for the VM (run: terraform output -json vm_password)"
  value       = module.sc_docker_vm.user_password
  sensitive   = true
}

output "dh01_vm_id" {
  description = "Proxmox VM ID for the dh01 Docker VM"
  value       = module.dh01_docker_vm.vm_id
}

output "dh01_vm_name" {
  description = "Hostname of the dh01 Docker VM"
  value       = module.dh01_docker_vm.vm_name
}

output "dh01_admin_password" {
  description = "Admin password for the dh01 VM (run: terraform output -json dh01_admin_password)"
  value       = module.dh01_docker_vm.admin_password
  sensitive   = true
}
