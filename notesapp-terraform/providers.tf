terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "kubernetes" {
  # Sur la VM Ubuntu
  config_path = "/home/redaa/.kube/config"
}
