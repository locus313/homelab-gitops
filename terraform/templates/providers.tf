terraform {
  required_providers {
    hypercore = {
      source  = "ScaleComputing/hypercore"
      version = "1.4.0"
    }
  }
}

provider "hypercore" {
}
