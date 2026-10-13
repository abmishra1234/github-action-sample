terraform {
  required_version = ">= 1.1.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"

    }
  }
}
