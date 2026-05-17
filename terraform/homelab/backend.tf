terraform {
  backend "s3" {
    bucket                      = "homelab-terraform-state"
    key                         = "homelab/terraform.tfstate"
    endpoint                    = "https://sjc1.vultrobjects.com"
    region                      = "us-east-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
