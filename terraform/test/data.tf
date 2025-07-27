data "hypercore_vms" "template-vm" {
  name = "template-vm"
}

data "hypercore_nodes" "node_1" {
  peer_id = 1
}
