# Output the generated password (marked as sensitive)
output "ubuntu_password" {
  description = "Generated password for the ubuntu user"
  value       = module.test_vm.user_password
  sensitive   = true
}

# To view the password after apply, run:
# terraform output -raw ubuntu_password
