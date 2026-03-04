terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}
