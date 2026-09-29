data "azurerm_client_config" "current" {}

module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "kv" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"

  vault = {
    name                       = module.naming.key_vault.name_unique
    location                   = module.rg.groups.demo.location
    resource_group_name        = module.rg.groups.demo.name
    rbac_authorization_enabled = false

    access_policies = {
      policy_current = {
        object_id = data.azurerm_client_config.current.object_id
        key_permissions = [
          "all"
        ]
        secret_permissions = [
          "all"
        ]
        certificate_permissions = [
          "all"
        ]
        storage_permissions = [
          "all"
        ]
      }
    }
  }
}
