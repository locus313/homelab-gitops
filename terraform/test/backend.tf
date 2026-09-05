terraform {
  backend "s3" {
    bucket                      = "lo5t-homelab-terraform-state"
    key                         = "homelab/test/terraform.tfstate"
    endpoint                    = "https://fsn1.your-objectstorage.com"
    region                      = "fsn1"
    skip_region_validation      = true
    skip_credentials_validation = true
    # skip_requesting_account_id  = true
    skip_metadata_api_check = true
    # skip_s3_checksum            = true
    # use_path_style              = true
    # use_lockfile                = true
  }
}
