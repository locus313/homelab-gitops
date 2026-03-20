# Terraform and Provider Version Requirements

terraform {
  required_version = ">= 1.0"

  required_providers {
    hypercore = {
      source  = "ScaleComputing/hypercore"
      version = "1.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
