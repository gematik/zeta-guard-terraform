terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm",
      version = "~> 4.39"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes",
      version = "~> 2.28"
    }
    helm = {
      source  = "hashicorp/helm",
      version = "~> 2.13"
    }
  }

  # backend config is injected via -backend-config=backend.hcl
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig_path)
  }
}
