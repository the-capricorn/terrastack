# Module: virtual-data-disk

Deploys an Azure Local Virtual Hard Disk (`Microsoft.AzureStackHCI/virtualHardDisks`) for use as a data disk attached to a VM instance.

Uses the [AzAPI provider](https://registry.terraform.io/providers/azure/azapi/latest) against API version `2024-01-01`.

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

---

## Example usage

```hcl
module "data_disk" {
  source = "./modules/virtual-data-disk"

  name                = "vhd-data-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"

  disk_size_gb       = 256
  disk_file_format   = "vhdx"
  dynamic            = true
  hyper_v_generation = "V2"

  tags = {
    environment = "prod"
    team        = "platform"
  }
}
```

### Minimal example

```hcl
module "data_disk" {
  source = "./modules/virtual-data-disk"

  name                = "vhd-data-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"
  disk_size_gb        = 128
}
```

---

## Azure API Reference

| Resource | API Version | Reference |
|----------|-------------|-----------|
| `Microsoft.AzureStackHCI/virtualHardDisks` | `2024-01-01` | [virtualHardDisks – Terraform (AzAPI)](https://learn.microsoft.com/en-us/azure/templates/microsoft.azurestackhci/2024-01-01/virtualharddisks?pivots=deployment-language-terraform) |
| `Microsoft.AzureStackHCI/virtualHardDisks` | `2024-01-01` | [virtualHardDisks – REST API](https://learn.microsoft.com/en-us/rest/api/stackhci/virtual-hard-disks) |
| Extended Location (Custom Location) | — | [Custom Locations overview](https://learn.microsoft.com/en-us/azure/azure-arc/platform/conceptual-custom-locations) |

---

## Notes

- This resource is a standalone ARM resource (not an extension resource) — it supports top-level `location` and `tags`.
- `null` properties (`storage_path_id`, `logical_sector_bytes`, `physical_sector_bytes`, `block_size_bytes`) are omitted from the API payload by the AzAPI provider; the cluster applies its defaults.
- To attach a data disk to a VM, pass `virtual_hard_disk_id` output into the VM module's `data_disk_ids` variable (once supported).
- `containerId` in the API maps to `storage_path_id` — it references a `Microsoft.AzureStackHCI/storageContainers` resource ID.
