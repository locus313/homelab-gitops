# Ubuntu 20.04 LTS (Focal) cloud image
resource "hypercore_virtual_disk" "ubuntu-server-20-04-focal" {
  name       = "ubuntu-server-20.04-focal.img"
  source_url = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

# Ubuntu 22.04 LTS (Jammy) cloud image
resource "hypercore_virtual_disk" "ubuntu-server-22-04-jammy" {
  name       = "ubuntu-server-22.04-jammy.img"
  source_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

# Ubuntu 24.04 LTS (Noble) cloud image
resource "hypercore_virtual_disk" "ubuntu-server-24-04-noble" {
  name       = "ubuntu-server-24.04-noble.img"
  source_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
