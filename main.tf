terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "inode_depletion_incident" {
  source    = "./modules/inode_depletion_incident"

  providers = {
    shoreline = shoreline
  }
}