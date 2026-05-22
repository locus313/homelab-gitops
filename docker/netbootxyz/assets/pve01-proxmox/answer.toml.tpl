# Proxmox VE automated installation answer file template.
#
# Variables are substituted by generate-proxmox-answer.sh using envsubst.
# DO NOT commit .envrc — it contains the root password hash.
#
# Uses kebab-case keys (PVE 8.4+ canonical format; snake_case deprecated in 9.0).
# Reference: https://pve.proxmox.com/wiki/Automated_Installation

[global]
keyboard = "en-us"
country = "us"
fqdn = "${PVE01_FQDN}"
mailto = ""
timezone = "${TZ}"
root-password-hashed = "${PROXMOX_ROOT_PASSWORD_HASH}"

[network]
# DHCP — Proxmox will use whatever IP the DHCP server assigns.
# Change the static block below if you want a fixed IP from first boot.
source = "from-dhcp"

# Static IP alternative (uncomment and set source = "from-answer" above):
#   source = "from-answer"
#   cidr   = "192.168.1.10/24"
#   dns    = "192.168.1.1"
#   gateway = "192.168.1.1"
#   filter = { name = "eno1" }

[disk-setup]
filesystem = "ext4"
disk-list = ["${PROXMOX_DISK}"]
# ZFS alternative:
#   filesystem = "zfs"
#   zfs.raid = "raid0"
