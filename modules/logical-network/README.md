# Module: logical-network

Deploys an Azure Local Logical Network (`Microsoft.AzureStackHCI/logicalNetworks`) with exactly one embedded subnet.

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
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Overall CIDR address space for the logical network (e.g., ["10.0.0.0/16"]). Must contain at least one prefix. | `list(string)` | n/a | yes |
| <a name="input_custom_location_id"></a> [custom\_location\_id](#input\_custom\_location\_id) | Full resource ID of the Custom Location associated with the Azure Local cluster. | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Optional list of DNS server IP addresses applied at the logical network level. Subnet-level DHCP options override these. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to deploy the logical network (e.g., 'westeurope'). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the logical network. Must be 2-64 characters, starting and ending with an alphanumeric character. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that will contain the logical network. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet within the logical network. Must be 2-64 characters, starting and ending with an alphanumeric character. | `string` | n/a | yes |
| <a name="input_ip_allocation_method"></a> [ip\_allocation\_method](#input\_ip\_allocation\_method) | IP allocation method for the subnet ('Dynamic' or 'Static'). | `string` | `"Dynamic"` | no |
| <a name="input_vlan"></a> [vlan](#input\_vlan) | Optional VLAN ID for the subnet (1-4094). Set to null to disable VLAN tagging. | `number` | `null` | no |
| <a name="input_ip_pool_start"></a> [ip\_pool\_start](#input\_ip\_pool\_start) | First IP address of the static IP pool (e.g. "10.10.10.10"). Must be set together with ip\_pool\_end. | `string` | `null` | no |
| <a name="input_ip_pool_end"></a> [ip\_pool\_end](#input\_ip\_pool\_end) | Last IP address of the static IP pool (e.g. "10.10.10.250"). Must be set together with ip\_pool\_start. | `string` | `null` | no |
| <a name="input_default_gateway"></a> [default\_gateway](#input\_default\_gateway) | Optional default gateway IP address. If set, a 0.0.0.0/0 route is added to the subnet's route table. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the logical network resource. | `map(string)` | `{}` | no |
| <a name="input_vm_switch_name"></a> [vm\_switch\_name](#input\_vm\_switch\_name) | Name of the VM switch on the Azure Local cluster to bind to this logical network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The name of the logical network. |
| <a name="output_logical_network_id"></a> [logical\_network\_id](#output\_logical\_network\_id) | The resource ID of the logical network. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Logical network resource ID used as `subnet.id` in NIC ipConfigurations. The HCI API references the logical network directly — subnets are not separate ARM sub-resources. |
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | The configured address space of the logical network. |
<!-- END_TF_DOCS -->

---

## Example usage

```hcl
module "logical_network" {
  source = "./modules/logical-network"

  name                = "lnet-prod-westeu-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"
  vm_switch_name      = "ConvergedSwitch"
  address_space       = ["10.10.0.0/16"]
  dns_servers         = ["10.10.0.4", "10.10.0.5"]

  subnet_name          = "snet-workload"
  ip_allocation_method = "Static"
  vlan                 = 100
  ip_pool_start        = "10.10.0.10"
  ip_pool_end          = "10.10.0.250"
  default_gateway      = "10.10.0.254"

  tags = {
    environment = "prod"
    team        = "platform"
  }
}
```

### Minimal example (no VLAN, Dynamic IP)

```hcl
module "logical_network" {
  source = "./modules/logical-network"

  name                = "lnet-dev-westeu-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-dev"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-dev"
  vm_switch_name      = "ConvergedSwitch"
  address_space       = ["10.20.0.0/24"]
  subnet_name         = "snet-workload"
}
```

---

## Azure API Reference

This module provisions resources using the Azure Stack HCI REST API.
Use the links below to look up property names, allowed values, and API constraints directly.

| Resource | API Version | Reference |
|----------|-------------|-----------|
| `Microsoft.AzureStackHCI/logicalNetworks` | `2024-01-01` | [logicalNetworks – Terraform (AzAPI)](https://learn.microsoft.com/en-us/azure/templates/microsoft.azurestackhci/2024-01-01/logicalnetworks?pivots=deployment-language-terraform) |
| `Microsoft.AzureStackHCI/logicalNetworks` | `2024-01-01` | [logicalNetworks – REST API](https://learn.microsoft.com/en-us/rest/api/stackhci/logical-networks) |
| Extended Location (Custom Location) | — | [Custom Locations overview](https://learn.microsoft.com/en-us/azure/azure-arc/platform/conceptual-custom-locations) |

> **Latest API versions:** Check the [change log](https://learn.microsoft.com/en-us/azure/templates/microsoft.azurestackhci/change-log/logicalnetworks) before upgrading the `type` string in `main.tf`.

---

## Notes

- Subnets are embedded in the logical network body; they are **not** separate ARM sub-resources. When attaching a NIC, pass the `subnet_id` output (which equals the logical network resource ID) — not a constructed `/subnets/<name>` path.
- The `custom_location_id` must reference the Custom Location of the target Azure Local cluster. Provider-level authentication is expected to be configured externally (e.g., via environment variables or a federated identity).
- No backend block, no hardcoded subscription or tenant IDs.
