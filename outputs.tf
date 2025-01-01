output "this" {
  value = azurerm_resource_group.this
}

output "ssh_key" {
  value = var.master_key == null ? null : azurerm_ssh_public_key.this[0]
}

output "vnet" {
  value = var.vnet_address_space == null ? null : module.vnet[0].this
}

output "subnet_ids" {
  value = [for m in module.subnets : m.this.id]
}

output "nat_gateway_public_ip" {
  value = var.nat_gateway ? module.nat_gateway[0].public_ip.ip_address : null
}

output "vnet_gateway_public_ip" {
  value = var.vnet_gateway == null ? null : module.vnet_gateway[0].public_ip.ip_address
}

output "vnet_gateway_subnet_id" {
  value = var.vnet_gateway == null ? null : module.vnet_gateway[0].subnet_id
}

output "storage_accounts" {
  value = module.storage_accounts
}

output "subnet_newbits" {
  value = var.subnet_newbits
}