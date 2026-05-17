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
