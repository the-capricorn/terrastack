# Module: windows-vm

Deploys an Azure Local Windows VM (`Microsoft.AzureStackHCI/virtualMachineInstances`) attached to a pre-existing Arc machine (`Microsoft.HybridCompute/machines`).

Uses the [AzAPI provider](https://registry.terraform.io/providers/azure/azapi/latest) against API version `2024-01-01`.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.0.0, < 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arc_machine_id"></a> [arc\_machine\_id](#input\_arc\_machine\_id) | Full resource ID of the existing Microsoft.HybridCompute/machines resource that this VM instance will be attached to. | `string` | n/a | yes |
| <a name="input_custom_location_id"></a> [custom\_location\_id](#input\_custom\_location\_id) | Full resource ID of the Custom Location associated with the Azure Local cluster. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to deploy the VM instance (e.g., 'westeurope'). Must match the Arc machine's region. | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Resource ID of the gallery image or marketplace gallery image used to provision the OS disk. | `string` | n/a | yes |
| <a name="input_storage_path_id"></a> [storage\_path\_id](#input\_storage\_path\_id) | Resource ID of the Microsoft.AzureStackHCI/storageContainers resource where VM configuration files are stored. | `string` | n/a | yes |
| <a name="input_network_interface_ids"></a> [network\_interface\_ids](#input\_network\_interface\_ids) | List of Microsoft.AzureStackHCI/networkInterfaces resource IDs to attach to this VM. At least one is required. | `list(string)` | n/a | yes |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Administrator password for the Windows VM. Must meet Azure password complexity requirements. | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Administrator username for the Windows VM. | `string` | `"azureadmin"` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | Windows NetBIOS computer name (max 15 characters, no dots or spaces). If null, the platform assigns one. Must be set explicitly when the Arc machine name is an FQDN (e.g., host.domain.com). | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | VM size to use. Set to 'Custom' and provide cpu\_count and memory\_mb for custom sizing, or use a predefined size (e.g., 'Standard\_D4s\_v3'). | `string` | `"Custom"` | no |
| <a name="input_cpu_count"></a> [cpu\_count](#input\_cpu\_count) | Number of virtual CPUs to assign. Used only when vm\_size = 'Custom'. | `number` | `2` | no |
| <a name="input_memory_mb"></a> [memory\_mb](#input\_memory\_mb) | Amount of RAM in megabytes. Used only when vm\_size = 'Custom'. | `number` | `4096` | no |
| <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates) | Enable Windows automatic updates on the VM. | `bool` | `false` | no |
| <a name="input_enable_tpm"></a> [enable\_tpm](#input\_enable\_tpm) | Enable the virtual Trusted Platform Module (vTPM). Required for TrustedLaunch and Confidential VM security types. | `bool` | `false` | no |
| <a name="input_secure_boot_enabled"></a> [secure\_boot\_enabled](#input\_secure\_boot\_enabled) | Enable UEFI Secure Boot on the VM. Requires enable\_tpm = true. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the VM instance resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_instance_id"></a> [vm\_instance\_id](#output\_vm\_instance\_id) | The resource ID of the virtual machine instance. |
| <a name="output_arc_machine_id"></a> [arc\_machine\_id](#output\_arc\_machine\_id) | The resource ID of the parent Arc machine (pass-through of var.arc\_machine\_id). |
| <a name="output_name"></a> [name](#output\_name) | The name of the Arc machine that this VM instance is attached to. |
<!-- END_TF_DOCS -->

---

## Example usage

```hcl
module "windows_vm" {
  source = "./modules/windows-vm"

  arc_machine_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.HybridCompute/machines/vm-prod-001.corp.example.com"
  custom_location_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"
  location           = "westeurope"

  image_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.AzureStackHCI/marketplaceGalleryImages/windows-server-2025-datacenter-azure-edition-core-smalldisk"
  storage_path_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.AzureStackHCI/storageContainers/UserStorage1-a1b2c3d4"

  network_interface_ids = [module.network_interface.network_interface_id]

  # When the Arc machine name is an FQDN, computer_name must be set explicitly.
  # Windows NetBIOS name: max 15 chars, alphanumeric and hyphens only.
  computer_name  = "vm-prod-001"
  admin_username = "azureadmin"
  admin_password = var.vm_admin_password  # inject via TF_VAR or secrets file

  cpu_count = 4
  memory_mb = 8192

  tags = {
    environment = "prod"
    team        = "platform"
  }
}
```

### Minimal example (default Custom sizing, no computer_name)

```hcl
module "windows_vm" {
  source = "./modules/windows-vm"

  arc_machine_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.HybridCompute/machines/vm-dev-001"
  custom_location_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-dev"
  location              = "westeurope"
  image_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.AzureStackHCI/marketplaceGalleryImages/windows-server-2025"
  storage_path_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.AzureStackHCI/storageContainers/UserStorage1-dev"
  network_interface_ids = [module.network_interface.network_interface_id]
  admin_password        = var.vm_admin_password
}
```

---

## Azure API Reference

| Resource | API Version | Reference |
|----------|-------------|-----------|
| `Microsoft.AzureStackHCI/virtualMachineInstances` | `2024-01-01` | [virtualMachineInstances – REST API](https://learn.microsoft.com/en-us/rest/api/stackhci/virtual-machine-instances/create-or-update?view=rest-stackhci-2024-01-01) |
| `Microsoft.AzureStackHCI/virtualMachineInstances` | `2024-01-01` | [virtualMachineInstances – Terraform (AzAPI)](https://learn.microsoft.com/en-us/azure/templates/microsoft.azurestackhci/2024-01-01/virtualmachineinstances?pivots=deployment-language-terraform) |
| `Microsoft.HybridCompute/machines` | — | [Arc-enabled servers overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview) |
| Extended Location (Custom Location) | — | [Custom Locations overview](https://learn.microsoft.com/en-us/azure/azure-arc/platform/conceptual-custom-locations) |

> **Latest API versions:** Check the [change log](https://learn.microsoft.com/en-us/azure/templates/microsoft.azurestackhci/change-log/virtualmachineinstances) before upgrading the `type` string in `main.tf`.

---

## Notes

- The VM instance resource is **always named `default`** — this is enforced by the HCI API. The logical name of the VM comes from the parent Arc machine.
- This module does **not** create the Arc machine (`Microsoft.HybridCompute/machines`). The Arc machine must already be registered on the Azure Local cluster before applying this module. Pass its full resource ID as `arc_machine_id`.
- **`computer_name` and FQDNs:** Arc machines registered on domain-joined clusters often have FQDN names (e.g., `vm-001.corp.example.com`). These are invalid Windows NetBIOS computer names (max 15 chars, no dots). Always set `computer_name` explicitly in that case.
- **`admin_password` security:** The password is marked `sensitive` and will not appear in plan output. However, it is stored in the Terraform state file. Use a remote backend with encryption at rest (e.g., Azure Storage with CMK) and do not commit passwords to `terraform.tfvars`. Use a gitignored `secrets.auto.tfvars` file or inject via `-var` at apply time.
- **`storage_path_id`** must reference a `Microsoft.AzureStackHCI/storageContainers` resource that exists on the target Azure Local cluster.
- **`image_id`** can reference either a `Microsoft.AzureStackHCI/galleryImages` (custom uploaded image) or `Microsoft.AzureStackHCI/marketplaceGalleryImages` (Azure Marketplace image downloaded to the cluster).
