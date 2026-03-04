# ----------------------------------------------------------------------------
# LOCAL VALUES: Pre-calculated helper values
# ----------------------------------------------------------------------------
locals {
  #   /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-azlocal-prod
  resource_group_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  resource_type = "Microsoft.AzureStackHCI/virtualHardDisks@2024-01-01"
}
