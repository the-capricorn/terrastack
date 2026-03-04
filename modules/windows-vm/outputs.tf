output "vm_instance_id" {
  description = "The resource ID of the virtual machine instance."
  value       = azapi_resource.vm_instance.id
}

output "arc_machine_id" {
  description = "The resource ID of the Arc machine (Microsoft.HybridCompute/machines) created for this VM."
  value       = azapi_resource.arc_machine.id
}

output "name" {
  description = "The name of the VM (and its Arc machine)."
  value       = azapi_resource.arc_machine.name
}
