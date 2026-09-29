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

## No admins
module "kv1" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"

  vault = {
    enable_role_assignment = false
    name                   = "${module.naming.key_vault.name_unique}1"
    location               = module.rg.groups.demo.location
    resource_group_name    = module.rg.groups.demo.name
  }
}

## Multiple admins
module "kv2" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"

  vault = {
    admins              = [data.azurerm_client_config.current.object_id]
    name                = "${module.naming.key_vault.name_unique}2"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}
