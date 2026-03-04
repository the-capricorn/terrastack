output "name" {
  description = "Name of the AKS Arc cluster."
  value       = azapi_resource.connected_cluster.name
}

output "connected_cluster_id" {
  description = "Resource ID of the Arc connected cluster (Microsoft.Kubernetes/connectedClusters)."
  value       = azapi_resource.connected_cluster.id
}

output "provisioned_cluster_id" {
  description = "Resource ID of the AKS Arc provisioned cluster instance (Microsoft.HybridContainerService/provisionedClusterInstances/default)."
  value       = azapi_resource.provisioned_cluster.id
}
