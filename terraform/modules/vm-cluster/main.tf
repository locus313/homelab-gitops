# VM Cluster Module - Creates a cluster of multiple VMs

# Create multiple VMs using the VM module
module "cluster_nodes" {
  source = "../vm"
  count  = var.node_count

  name        = "${var.cluster_name}-node-${count.index + 1}"
  description = "${var.cluster_description} - Node ${count.index + 1}"
  tags        = concat(var.tags, ["cluster:${var.cluster_name}", "node:${count.index + 1}"])
  
  vcpu   = var.vcpu
  memory = var.memory

  template_vm_uuid        = var.template_vm_uuid
  meta_data_template_path = var.meta_data_template_path
  user_data_template_path = var.user_data_template_path
  
  ssh_authorized_keys = var.ssh_authorized_keys
  ssh_import_id       = var.ssh_import_id
  user_password       = var.user_password
  
  disk_type              = var.disk_type
  disk_size              = var.disk_size
  source_virtual_disk_id = var.source_virtual_disk_id
  
  nic_type = var.nic_type
  vlan     = var.vlan
  
  affinity_strategy = var.affinity_strategy
  power_state       = var.power_state
}
