terraform {
  backend "s3" {
    bucket                      = "lo5t-homelab-terraform-state"
    key                         = "portainer/terraform.tfstate"
    endpoint                    = "https://fsn1.your-objectstorage.com"
    region                      = "fsn1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
