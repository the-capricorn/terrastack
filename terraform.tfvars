# ----------------------------------------------------------------------------
# Shared
# ----------------------------------------------------------------------------
location = "westeurope"

# resource_group_name is intentionally absent here.
# Inject at runtime via TF_VAR_resource_group_name or locally:
#   export TF_VAR_resource_group_name="<resource-group>"
vm_switch_name = "ConvergedSwitch(compute_management)"

# Resource ID of the Key Vault where Linux VM SSH private keys are stored.
# Format: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv-name>
key_vault_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>"

tags = {
  environment = "test"
  team        = "platform"
}

# custom_location_id is intentionally absent here.
# It is injected at runtime via the TF_VAR_custom_location_id secret
# (GitHub Actions) or by setting the environment variable locally:
#   export TF_VAR_custom_location_id="<resource-id>"

# ----------------------------------------------------------------------------
# Logical Networks
# ----------------------------------------------------------------------------
networks = [
  {
    name                 = "n-spoke-230-testing"
    address_space        = ["10.40.230.0/24"]
    subnet_name          = "sub-n-spoke-230-testing"
    vlan                 = 230
    ip_allocation_method = "Static"
    ip_pool_start        = "10.40.230.10"
    ip_pool_end          = "10.40.230.200"
    default_gateway      = "10.40.230.254"
    dns_servers          = ["10.40.128.100", "10.50.128.200"]
    tags = {
      env     = "dev"
      creator = "thomas.steinbock"
    }
  },
]

# ----------------------------------------------------------------------------
# Network Interfaces
# ----------------------------------------------------------------------------
network_interfaces = [
  # {
  #   name                 = "nic-<vm-name>"
  #   logical_network_name = "n-spoke-230-testing"
  #   private_ip_address   = "10.40.230.21"
  # },
]

# ----------------------------------------------------------------------------
# Virtual Machines (Windows)
# ----------------------------------------------------------------------------
# admin_password must NOT be committed. Set it in the gitignored secrets.auto.tfvars.
#
# image_id:
#   /subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image-name>
virtual_machines = [
  # {
  #   name     = "windowsvm01.corp.local"
  #   image_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image-name>"
  #
  #   network_interface_names = ["nic-windowsvm01"]
  #
  #   computer_name = "windowsvm01"   # max 15 chars, no dots
  #   vm_size       = "Standard_A4_v2"
  #
  #   # admin_password: set in secrets.auto.tfvars, NOT here.
  # },
]

# ----------------------------------------------------------------------------
# Virtual Data Disks
# ----------------------------------------------------------------------------
data_disks = [
  # {
  #   name         = "vhd-<vm-name>-data"
  #   disk_size_gb = 128
  #   # disk_file_format  = "vhdx"   # default: vhdx
  #   # dynamic           = true     # default: true (dynamically expanding)
  #   # hyper_v_generation = "V2"    # default: null (cluster decides)
  # },
]

# ----------------------------------------------------------------------------
# AKS Arc Clusters
# ----------------------------------------------------------------------------
# SSH key pairs are generated automatically — private key stored in Key Vault (key_vault_id above).
# Retrieve with: az keyvault secret show --vault-name <kv> --name ssh-aks-<cluster-name> --query value -o tsv
#
aks_clusters = [
  {
    name                 = "testaks"
    logical_network_name = "n-spoke-230-testing"

    # kubernetes_version omitted — API uses cluster default. Check available versions with:
    # az aksarc get-versions --custom-location <custom-location-id> --output table
    control_plane_ip      = "10.40.230.20" # static IP for the API server, from the pool
    control_plane_count   = 1
    control_plane_vm_size = "Standard_A4_v2"

    node_pools = [
      {
        name    = "nodepool1"
        count   = 2
        vm_size = "Standard_A4_v2"
        os_sku  = "CBLMariner"
      },
    ]
  },
]

# ----------------------------------------------------------------------------
# Linux Virtual Machines
# ----------------------------------------------------------------------------
# admin_password must NOT be committed. Set it in the gitignored secrets.auto.tfvars.
# SSH key pairs are generated automatically — private key stored in Key Vault (key_vault_id above).
# Retrieve with: az keyvault secret show --vault-name <kv> --name ssh-<vm-name> --query value -o tsv
#
linux_vms = [
  # {
  #   name     = "linuxvm01.corp.local"
  #   image_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image-name>"
  #
  #   network_interface_names = ["nic-linuxvm01"]
  #
  #   computer_name = "linuxvm01"
  #   vm_size       = "Standard_A4_v2"
  #
  #   # admin_password: set in secrets.auto.tfvars, NOT here.
  # },
]
