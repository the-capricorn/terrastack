# ----------------------------------------------------------------------------
# RESOURCE: Arc Machine (Microsoft.HybridCompute/machines)
# ----------------------------------------------------------------------------
# Creates the Arc machine that acts as the parent for the VM instance.
# For Azure Local VMs, this is a lightweight placeholder resource with kind = "HCI".
# The actual VM configuration lives in the virtualMachineInstances extension below.
resource "azapi_resource" "arc_machine" {
  type      = local.arc_machine_type
  name      = var.name
  parent_id = local.resource_group_id
  location  = var.location

  identity {
    type = "SystemAssigned"
  }

  body = {
    kind       = "HCI"
    properties = {}
  }
}

# ----------------------------------------------------------------------------
# RESOURCE: Azure Stack HCI Virtual Machine Instance
# ----------------------------------------------------------------------------
resource "azapi_resource" "vm_instance" {

  # The exact Azure resource type and API version to use.
  type = local.vm_instance_type

  # The VM instance is always named "default" — this is enforced by the HCI API.
  name = "default"

  # Parent is the Arc machine created above.
  parent_id = azapi_resource.arc_machine.id

  # virtualMachineInstances is an extension resource — it inherits location from
  # the parent Arc machine and does not support top-level location or tags in its schema.

  # The "body" is the full configuration payload sent to the Azure API.
  body = {

    # Extended Location links this VM to a specific Azure Local cluster.
    extendedLocation = {
      name = var.custom_location_id
      type = "CustomLocation"
    }

    properties = {

      # Hardware sizing — assembled in locals above.
      hardwareProfile = local.hardware_profile

      # OS configuration.
      osProfile = {
        computerName  = var.computer_name
        adminUsername = var.admin_username
        adminPassword = var.admin_password
        linuxConfiguration = {
          disablePasswordAuthentication = false
          ssh = {
            publicKeys = [
              {
                keyData = var.ssh_public_key
                path    = local.ssh_public_key_path
              }
            ]
          }
        }
      }

      storageProfile = {
        # The gallery image or marketplace image used to provision the OS disk.
        imageReference = { id = var.image_id }

        # Storage container where VM configuration files (VMCX, etc.) are stored.
        # Null is omitted by AzAPI — the cluster default storage path is used.
        vmConfigStoragePathId = var.storage_path_id
      }

      networkProfile = {
        # One or more pre-created HCI network interface resource IDs.
        networkInterfaces = [for nic_id in var.network_interface_ids : { id = nic_id }]
      }

      securityProfile = {
        enableTPM    = var.enable_tpm
        uefiSettings = { secureBootEnabled = var.secure_boot_enabled }
      }
    }
  }
}
