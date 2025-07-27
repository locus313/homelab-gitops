terraform {
   backend "s3" {
     bucket                      = "homelab-terraform-state"
     key                         = "homelab/test/terraform.tfstate"
     endpoints                   = { s3 = "https://sjc1.vultrobjects.com" }
     region                      = "us-east-1"
     skip_region_validation      = true
     skip_credentials_validation = true
     skip_requesting_account_id  = true
     skip_metadata_api_check     = true
     skip_s3_checksum            = true
     use_path_style              = true
     use_lockfile                = true
   }
 }
