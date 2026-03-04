# ----------------------------------------------------------------------------
# RESOURCE: Azure Stack HCI Logical Network
# ----------------------------------------------------------------------------
resource "azapi_resource" "logical_network" {

  # The exact Azure resource type and API version to use.
  # Changing the API version here could affect which features are available.
  type = local.resource_type

  # The display name of the logical network as it appears in the Azure Portal.
  name = var.name

  # The Resource Group this network will live in (calculated above in locals).
  parent_id = local.resource_group_id

  # The Azure region where the resource is deployed (e.g. "westeurope").
  location = var.location

  # Example: { environment = "prod", team = "platform" }
  tags = var.tags

  # The "body" is the full configuration payload sent to the Azure API.
  body = {

    # Extended Location links this logical network to a specific Azure Local
    # cluster (on-premises hardware).
    extendedLocation = {
      name = var.custom_location_id
      type = "CustomLocation"
    }

    properties = {

      # The name of the virtual switch on the Azure Local cluster that this
      # logical network should be bound to.
      vmSwitchName = var.vm_switch_name

      # DNS servers for this network. If the list is empty, this
      # property is skipped entirely (null) so the API uses its own defaults.
      dhcpOptions = length(var.dns_servers) > 0 ? { dnsServers = var.dns_servers } : null

      # The subnet definition is assembled in the locals block above.
      subnets = [local.subnet_body]
    }
  }
}
