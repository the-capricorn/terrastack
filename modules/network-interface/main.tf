# ----------------------------------------------------------------------------
# RESOURCE: Azure Stack HCI Network Interface
# ----------------------------------------------------------------------------
resource "azapi_resource" "network_interface" {

  # The exact Azure resource type and API version to use.
  type = local.resource_type

  # The display name of the NIC as it appears in the Azure Portal.
  name = var.name

  # The Resource Group this NIC will live in (calculated above in locals).
  parent_id = local.resource_group_id

  # The Azure region where the resource is deployed (e.g. "westeurope").
  location = var.location

  # Example: { environment = "prod", team = "platform" }
  tags = var.tags

  # The "body" is the full configuration payload sent to the Azure API.
  body = {

    # Extended Location links this NIC to a specific Azure Local cluster.
    extendedLocation = {
      name = var.custom_location_id
      type = "CustomLocation"
    }

    properties = {

      # IP configuration assembled in locals above.
      ipConfigurations = [local.ip_config_body]

      # NIC-level DNS servers — omitted (null) if list is empty.
      dnsSettings = length(var.dns_servers) > 0 ? { dnsServers = var.dns_servers } : null

      # MAC address — omitted if null (auto-assigned by the platform).
      macAddress = var.mac_address
    }
  }
}
