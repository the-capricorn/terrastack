output "virtual_hard_disk_id" {
  description = "The resource ID of the virtual hard disk."
  value       = azapi_resource.virtual_hard_disk.id
}

output "name" {
  description = "The name of the virtual hard disk."
  value       = azapi_resource.virtual_hard_disk.name
}
