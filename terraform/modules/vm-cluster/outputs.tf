# VM Cluster Module Outputs

output "cluster_name" {
  description = "Name of the cluster"
  value       = var.cluster_name
}

output "node_count" {
  description = "Number of nodes in the cluster"
  value       = var.node_count
}

output "vm_ids" {
  description = "List of VM UUIDs for all cluster nodes"
  value       = [for node in module.cluster_nodes : node.vm_id]
}

output "vm_names" {
  description = "List of VM names for all cluster nodes"
  value       = [for node in module.cluster_nodes : node.vm_name]
}

output "disk_ids" {
  description = "List of disk IDs for all cluster nodes"
  value       = [for node in module.cluster_nodes : node.disk_id]
}

output "nic_ids" {
  description = "List of NIC IDs for all cluster nodes"
  value       = [for node in module.cluster_nodes : node.nic_id]
}

output "user_passwords" {
  description = "Map of VM names to their generated/provided passwords"
  value       = { for node in module.cluster_nodes : node.vm_name => node.user_password }
  sensitive   = true
}

output "nodes" {
  description = "Complete node information as a map"
  value = {
    for idx, node in module.cluster_nodes : "${var.cluster_name}-node-${idx + 1}" => {
      vm_id   = node.vm_id
      disk_id = node.disk_id
      nic_id  = node.nic_id
      tags    = node.vm_tags
    }
  }
}
