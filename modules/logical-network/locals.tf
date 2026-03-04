# ----------------------------------------------------------------------------
# LOCAL VALUES: Pre-calculated helper values
# ----------------------------------------------------------------------------
locals {
  #   /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-azlocal-prod
  resource_group_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  # merge() combines multiple maps into one, skipping empty maps {} for optional fields.
  subnet_body = {
    name = var.subnet_name
    properties = merge(
      {
        addressPrefix      = var.address_space[0]
        ipAllocationMethod = var.ip_allocation_method
      },
      # VLAN tagging — omitted if null.
      var.vlan != null ? { vlan = var.vlan } : {},
      # IP pool — defines the assignable address range for VMs (required for Static allocation).
      var.ip_pool_start != null ? {
        ipPools = [{
          start = var.ip_pool_start
          end   = var.ip_pool_end
        }]
      } : {},
      # Default gateway — adds a 0.0.0.0/0 route so VMs can reach external networks.
      var.default_gateway != null ? {
        routeTable = {
          properties = {
            routes = [{
              properties = {
                addressPrefix    = "0.0.0.0/0"
                nextHopIpAddress = var.default_gateway
              }
            }]
          }
        }
      } : {}
    )
  }

  resource_type = "Microsoft.AzureStackHCI/logicalNetworks@2024-01-01"
}
