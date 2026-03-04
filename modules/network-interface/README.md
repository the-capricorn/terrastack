# Module: network-interface

Deploys an Azure Local Network Interface (`Microsoft.AzureStackHCI/networkInterfaces`) and attaches it to a logical network.

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
| <a name="input_name"></a> [name](#input\_name) | Name of the network interface. Must be 1-80 characters, starting and ending with an alphanumeric character. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to deploy the network interface (e.g., 'westeurope'). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that will contain the network interface. | `string` | n/a | yes |
| <a name="input_custom_location_id"></a> [custom\_location\_id](#input\_custom\_location\_id) | Full resource ID of the Custom Location associated with the Azure Local cluster. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Logical network resource ID to attach this NIC to. Use the `subnet_id` output of the logical-network module. The HCI API field is named `subnet.id` but takes the logical network resource ID directly. | `string` | n/a | yes |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Optional static private IP address. If null, the IP is assigned from the logical network's IP pool. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Optional list of DNS server IP addresses at the NIC level. Overrides logical network DNS settings. | `list(string)` | `[]` | no |
| <a name="input_mac_address"></a> [mac\_address](#input\_mac\_address) | Optional MAC address. If null, one is auto-assigned by the platform. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the network interface resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The name of the network interface. |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | The resource ID of the network interface. |
<!-- END_TF_DOCS -->

---

## Example usage

```hcl
module "network_interface" {
  source = "./modules/network-interface"

  name                = "nic-vm-prod-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"

  # subnet_id comes from the logical-network module output
  subnet_id          = module.logical_network.subnet_id
  private_ip_address = "10.10.10.20"

  tags = {
    environment = "prod"
    team        = "platform"
  }
}
```

### Minimal example (no static IP, no DNS)

```hcl
module "network_interface" {
  source = "./modules/network-interface"

  name                = "nic-vm-dev-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-dev"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-dev/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-dev"
  subnet_id           = module.logical_network.subnet_id
}
```

---

## Azure API Reference

| Resource | API Version | Reference |
|----------|-------------|-----------|
| `Microsoft.AzureStackHCI/networkInterfaces` | `2024-01-01` | [networkInterfaces – REST API](https://learn.microsoft.com/en-us/rest/api/stackhci/network-interfaces/create-or-update?view=rest-stackhci-2024-01-01) |
| Extended Location (Custom Location) | — | [Custom Locations overview](https://learn.microsoft.com/en-us/azure/azure-arc/platform/conceptual-custom-locations) |

---

## Notes

- Pass the `subnet_id` output from the `logical-network` module directly as `subnet_id`.
  Despite the field name, the HCI API expects the logical network resource ID — not a sub-resource path.
- When `private_ip_address` is null, the IP is assigned from the logical network's IP pool (requires `ip_pool_start`/`ip_pool_end` to be configured on the logical network).
- The `custom_location_id` must match the one used for the associated logical network.
