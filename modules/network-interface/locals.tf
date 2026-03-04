# ----------------------------------------------------------------------------
# LOCAL VALUES: Pre-calculated helper values
# ----------------------------------------------------------------------------
locals {
  #   /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-azlocal-prod
  resource_group_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  # IP configuration body pre-assembled for readability (same pattern as subnet_body in logical-network).
  ip_config_body = {
    name = var.name
    properties = merge(
      { subnet = { id = var.subnet_id } },
      # Static IP address — omitted if null (IP assigned from pool instead).
      var.private_ip_address != null ? { privateIPAddress = var.private_ip_address } : {}
    )
  }

  resource_type = "Microsoft.AzureStackHCI/networkInterfaces@2024-01-01"
}
