output "name" {
  description = "The name of the network interface."
  value       = azapi_resource.network_interface.name
}

output "network_interface_id" {
  description = "The resource ID of the network interface."
  value       = azapi_resource.network_interface.id
}
