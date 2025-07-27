module "cloud-images" {
  source = "../modules/cloud-images"
}

resource "hypercore_vm" "template-vm" {
  tags        = ["templates"]
  name        = "template-vm"
  description = "template VM"

  vcpu              = 4
  memory            = 4096 # MiB
  affinity_strategy = {}
}
