output "name" {
  description = "The name of the logical network."
  value       = azapi_resource.logical_network.name
}

output "logical_network_id" {
  description = "The resource ID of the logical network."
  value       = azapi_resource.logical_network.id
}

output "subnet_id" {
  description = "Logical network resource ID used as subnet.id in NIC ipConfigurations. The Azure Stack HCI API references the logical network directly — subnets are embedded in the logical network body, not separate ARM sub-resources."
  value       = azapi_resource.logical_network.id
}

output "address_space" {
  description = "The configured address space of the logical network."
  value       = var.address_space
}
