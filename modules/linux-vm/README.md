# Module: linux-vm

Deploys an Azure Local Linux VM (`Microsoft.AzureStackHCI/virtualMachineInstances`) attached to an Arc machine (`Microsoft.HybridCompute/machines`) created by this module.

Uses the [AzAPI provider](https://registry.terraform.io/providers/azure/azapi/latest) against API version `2024-01-01`.

---

## Example usage

```hcl
module "linux_vm" {
  source = "./modules/linux-vm"

  name                = "linux-prod-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"

  image_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.AzureStackHCI/marketplaceGalleryImages/ubuntu-2204"
  storage_path_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.AzureStackHCI/storageContainers/UserStorage1-prod"

  network_interface_ids = [module.network_interface.network_interface_id]

  admin_username = "azureuser"
  admin_password = var.linux_admin_password  # inject via TF_VAR or secrets file
  ssh_public_key = var.linux_ssh_public_key  # inject via TF_VAR or secrets file

  computer_name = "linux-prod-001"
  vm_size       = "Standard_A4_v2"
}
```

---

## Notes

- The VM instance resource is **always named `default`** — this is enforced by the HCI API. The logical name of the VM comes from the parent Arc machine.
- **`admin_password` and `ssh_public_key` security:** Both are marked `sensitive` and will not appear in plan output. However, they are stored in the Terraform state file. Use a remote backend with encryption at rest and do not commit secrets to `terraform.tfvars`. Use a gitignored `secrets.auto.tfvars` file or inject via `-var` at apply time.
- **`storage_path_id`** must reference a `Microsoft.AzureStackHCI/storageContainers` resource that exists on the target Azure Local cluster.
- **`image_id`** can reference either a `Microsoft.AzureStackHCI/galleryImages` (custom uploaded image) or `Microsoft.AzureStackHCI/marketplaceGalleryImages` (Azure Marketplace image downloaded to the cluster).
