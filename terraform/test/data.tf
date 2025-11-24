locals {
  ubuntu_server_templates = {
    "20-04-focal" = {
      id   = "bfec743f-7494-46b8-871e-3d5165436432"
      name = "ubuntu-server-20.04-focal.img"
    }
    "22-04-jammy" = {
      id   = "3c29bea5-2771-4295-83ba-708c754bfdcb"
      name = "ubuntu-server-22.04-jammy.img"
    }
    "24-04-noble" = {
      id   = "a1b2c3d4-5678-90ab-cdef-1234567890ab"
      name = "ubuntu-server-24.04-noble.img"
    }
  }
}

data "hypercore_vms" "template-vm" {
  name = "template-vm"
}

data "hypercore_nodes" "node_1" {
  peer_id = 1
}

data "hypercore_nodes" "node_2" {
  peer_id = 2
}
