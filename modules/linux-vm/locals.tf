# ----------------------------------------------------------------------------
# LOCAL VALUES: Pre-calculated helper values
# ----------------------------------------------------------------------------
locals {
  #   /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-azlocal-prod
  resource_group_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  # Build hardwareProfile: Custom sizing includes explicit CPU/memory counts;
  # predefined sizes only use vmSize — processors and memoryMB are null (omitted by AzAPI).
  hardware_profile = {
    vmSize     = var.vm_size
    processors = var.vm_size == "Custom" ? var.cpu_count : null
    memoryMB   = var.vm_size == "Custom" ? var.memory_mb : null
  }

  ssh_public_key_path = "/home/${var.admin_username}/.ssh/authorized_keys"

  arc_machine_type = "Microsoft.HybridCompute/machines@2024-07-10"
  vm_instance_type = "Microsoft.AzureStackHCI/virtualMachineInstances@2024-01-01"
}
