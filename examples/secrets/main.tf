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
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      predefined_string = {
        connection_string = {
          value = "example-connection-string"
        }
      }
      random_string = {
        example-1 = {
          length  = 24
          special = false
        }
        example-2 = {
          length  = 24
          special = false
        }
      }
      tls_keys = {
        example = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }
  }
}
