# Output cluster information
output "cluster_nodes" {
  description = "Information about all nodes in the cluster"
  value       = module.test_cluster.nodes
}

output "cluster_vm_names" {
  description = "List of VM names in the cluster"
  value       = module.test_cluster.vm_names
}

output "cluster_passwords" {
  description = "Passwords for cluster nodes (use 'terraform output -json cluster_passwords' to view)"
  value       = module.test_cluster.user_passwords
  sensitive   = true
}
