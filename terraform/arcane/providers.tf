terraform {
  required_version = ">= 1.11"

  required_providers {
    arcane = {
      source  = "HellsCrimson/arcane"
      version = "= 2.0.0"
    }
  }
}

provider "arcane" {
  endpoint = var.arcane_endpoint
}
