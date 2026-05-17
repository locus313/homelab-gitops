locals {
  ubuntu_server_templates = {
    "22-04-jammy" = {
      id   = "3c29bea5-2771-4295-83ba-708c754bfdcb"
      name = "ubuntu-server-22.04-jammy.img"
    }
    "24-04-noble" = {
      id   = "157380b0-733c-4b65-9075-6a2934e8b621"
      name = "ubuntu-server-24.04-noble.img"
    }
    "26-04-resolute" = {
      id   = "df4acaee-92d8-4df8-9cf6-ffea4ae34c2f"
      name = "ubuntu-server-26.04-resolute.img"
    }
  }
}

data "hypercore_vms" "template-vm" {
  name = "template-vm"
}
