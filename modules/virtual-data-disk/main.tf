# ----------------------------------------------------------------------------
# RESOURCE: Azure Stack HCI Virtual Hard Disk
# ----------------------------------------------------------------------------
resource "azapi_resource" "virtual_hard_disk" {
  type      = local.resource_type
  name      = var.name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    extendedLocation = {
      name = var.custom_location_id
      type = "CustomLocation"
    }

    properties = {
      diskSizeGB          = var.disk_size_gb
      diskFileFormat      = var.disk_file_format
      dynamic             = var.dynamic
      hyperVGeneration    = var.hyper_v_generation
      containerId         = var.storage_path_id
      logicalSectorBytes  = var.logical_sector_bytes
      physicalSectorBytes = var.physical_sector_bytes
      blockSizeBytes      = var.block_size_bytes
    }
  }
}
