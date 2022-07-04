# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"


  backend "azurerm" {
    resource_group_name  = "tfstate1"
    storage_account_name = "mystorageank5647"
    container_name       = "tfstate1"
    key                  = "terraform.tfstate"
  }

}