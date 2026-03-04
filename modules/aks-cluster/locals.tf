# ----------------------------------------------------------------------------
# LOCAL VALUES: Pre-calculated helper values
# ----------------------------------------------------------------------------
locals {
  #   /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-azlocal-prod
  resource_group_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  connected_cluster_type   = "Microsoft.Kubernetes/connectedClusters@2024-01-01"
  provisioned_cluster_type = "Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01"
  agent_pool_type          = "Microsoft.HybridContainerService/provisionedClusterInstances/agentPools@2024-01-01"

  # First node pool goes into agentPoolProfiles in the main resource body.
  # Additional node pools are created as separate child resources.
  primary_node_pool     = var.node_pools[0]
  additional_node_pools = { for pool in slice(var.node_pools, 1, length(var.node_pools)) : pool.name => pool }
}
