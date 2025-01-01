variable "name" {
  type    = string
  default = null
}

variable "name_prefix" {
  default  = ""
  nullable = false
}

variable "location" {}

variable "master_key" {
  default = null
}

variable "vnet_address_space" {
  default = null
}

variable "nat_gateway" {
  default  = false
  nullable = false
}

variable "subnets" {
  default  = 1
  nullable = false
}

variable "subnet_newbits" {
  default  = 8
  nullable = false
}

variable "vnet_service_endpoints" {
  type    = set(string)
  default = null
}

variable "peering_connections" {
  type = map(object({
    id                  = string
    use_remote_gateways = optional(bool)
  }))
  default  = {}
  nullable = false
}

variable "vnet_gateway" {
  type = object({
    type          = optional(string, "Vpn")
    sku           = optional(string, "VpnGw1")
    vpn_type      = optional(string)
    subnet_index  = optional(number, 255)
    custom_routes = optional(list(string))
    vpn_client_configuration = optional(object({
      address_space        = set(string)
      protocols            = set(string)
      auth_types           = set(string)
      aad_tenant           = optional(string)
      aad_issuer           = optional(string)
      aad_audience         = optional(string)
      root_certificates    = optional(map(string), {})
      revoked_certificates = optional(map(string), {})
    }))
    connections = optional(map(object({
      type            = optional(string)
      gateway_id      = optional(string)
      gateway_address = optional(string)
      address_space   = optional(set(string))
      shared_key      = string
      ipsec_policy = optional(object({
        dh_group         = string
        ike_encryption   = string
        ike_integrity    = string
        ipsec_encryption = string
        ipsec_integrity  = string
        pfs_group        = string
        sa_lifetime      = optional(string)
      }))
    })), {})
  })
  default = null
}

variable "storage_accounts" {
  type = map(object({
    account_tier                      = optional(string)
    account_replication_type          = optional(string)
    queue_encryption_key_type         = optional(string)
    table_encryption_key_type         = optional(string)
    infrastructure_encryption_enabled = optional(bool)
    randomize_name                    = optional(bool)
  }))
  default  = {}
  nullable = false
}

variable "tags" {
  type     = map(string)
  default  = {}
  nullable = false
}