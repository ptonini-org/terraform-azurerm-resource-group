locals {
  name        = coalesce(var.name, "${var.name_prefix}-rg")
  name_prefix = coalesce(var.name, var.name_prefix)
}

resource "azurerm_resource_group" "this" {
  name     = coalesce(var.name, "${var.name_prefix}-rg")
  location = var.location
  tags     = var.tags
  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["environment_finops"],
      tags["environment"],
      tags["product"],
      tags["subscription_type"]
    ]
  }
}

resource "azurerm_ssh_public_key" "this" {
  count               = var.master_key == null ? 0 : 1
  name                = coalesce(var.name, "${var.name_prefix}-master-key")
  resource_group_name = upper(azurerm_resource_group.this.name)
  location            = azurerm_resource_group.this.location
  public_key          = var.master_key
  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["environment_finops"],
      tags["environment"],
      tags["product"],
      tags["subscription_type"]
    ]
  }
}

module "vnet" {
  source              = "app.terraform.io/ptonini-org/vnet/azurerm"
  version             = "~> 1.0.0"
  count               = var.vnet_address_space == null ? 0 : 1
  name                = coalesce(var.name, "${var.name_prefix}-vnet")
  rg                  = azurerm_resource_group.this
  address_space       = var.vnet_address_space
  peering_connections = var.peering_connections
}

module "nat_gateway" {
  source  = "app.terraform.io/ptonini-org/nat-gateway/azurerm"
  version = "~> 1.0.0"
  count   = var.nat_gateway ? 1 : 0
  name    = coalesce(var.name, "${var.name_prefix}-nat-gateway")
  rg      = azurerm_resource_group.this
}

module "subnets" {
  source               = "app.terraform.io/ptonini-org/subnet/azurerm"
  version              = "~> 1.0.0"
  count                = var.vnet_address_space == null ? 0 : var.subnets
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = module.vnet[0].this.name
  name                 = "subnet${format("%04.0f", count.index + 1)}"
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], var.subnet_newbits, count.index)]
  nat_gateway_id       = one(module.nat_gateway[*].this.id)
  service_endpoints    = var.vnet_service_endpoints
}

module "vnet_gateway" {
  source  = "app.terraform.io/ptonini-org/vnet-gateway/azurerm"
  version = "~> 1.0.0"
  count   = var.vnet_gateway == null ? 0 : 1
  name    = coalesce(var.name, "${var.name_prefix}-vnet-gateway")
  rg      = azurerm_resource_group.this
  subnet = {
    virtual_network_name = module.vnet[0].this.name
    address_prefixes     = [cidrsubnet(var.vnet_address_space[0], var.subnet_newbits, var.vnet_gateway.subnet_index)]
  }
  type                     = var.vnet_gateway.type
  sku                      = var.vnet_gateway.sku
  vpn_type                 = var.vnet_gateway.vpn_type
  custom_routes            = flatten(concat(var.vnet_gateway.custom_routes, var.vnet_address_space))
  vpn_client_configuration = var.vnet_gateway.vpn_client_configuration
  connections              = var.vnet_gateway.connections
}

module "storage_accounts" {
  source                            = "app.terraform.io/ptonini-org/storage-account/azurerm"
  version                           = "~> 1.0.0"
  for_each                          = var.storage_accounts
  name                              = each.key
  rg                                = azurerm_resource_group.this
  randomize_name                    = each.value.randomize_name
  account_tier                      = each.value.account_tier
  account_replication_type          = each.value.account_replication_type
  queue_encryption_key_type         = each.value.queue_encryption_key_type
  table_encryption_key_type         = each.value.table_encryption_key_type
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
}