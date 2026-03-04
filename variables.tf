# ----------------------------------------------------------------------------
# Shared
# ----------------------------------------------------------------------------
variable "location" {
  type        = string
  description = "Azure region in which to deploy all resources (e.g. 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain all resources."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "vm_switch_name" {
  type        = string
  description = "Name of the VM switch on the Azure Local cluster. Shared across all logical networks."
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault where Linux VM SSH private keys are stored as secrets."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources. Per-resource tags are merged on top of these."
  default     = {}
}

# ----------------------------------------------------------------------------
# Logical Networks
# ----------------------------------------------------------------------------
variable "networks" {
  description = "List of logical networks to deploy."
  type = list(object({
    name                 = string
    address_space        = list(string)
    subnet_name          = optional(string) # defaults to "snet-<name>" if omitted
    vlan                 = optional(number)
    ip_allocation_method = optional(string, "Static")
    ip_pool_start        = optional(string)
    ip_pool_end          = optional(string)
    default_gateway      = optional(string)
    dns_servers          = optional(list(string), [])
    tags                 = optional(map(string), {})
  }))
  default = []
}

# ----------------------------------------------------------------------------
# Network Interfaces
# ----------------------------------------------------------------------------
variable "network_interfaces" {
  description = "List of network interfaces to deploy. Each NIC references a logical network by name."
  type = list(object({
    name                 = string
    logical_network_name = string # must match a name in var.networks
    private_ip_address   = optional(string)
    dns_servers          = optional(list(string), [])
    mac_address          = optional(string)
    tags                 = optional(map(string), {})
  }))
  default = []
}

# ----------------------------------------------------------------------------
# Virtual Machines
# ----------------------------------------------------------------------------
variable "virtual_machines" {
  description = "List of Windows VM instances to deploy on the Azure Local cluster. The module creates the Arc machine (HybridCompute/machines) and VM instance for each entry."
  type = list(object({
    name                     = string                     # used as the Arc machine name and map key
    image_id                 = string                     # gallery image or marketplace gallery image resource ID
    storage_path_id          = optional(string)           # storageContainers resource ID for VM config files; null = cluster default
    network_interface_names  = optional(list(string), []) # names from var.network_interfaces (Terraform-managed NICs)
    network_interface_ids    = optional(list(string), []) # full resource IDs for externally-managed NICs
    vm_size                  = optional(string, "Custom")
    cpu_count                = optional(number, 2)
    memory_mb                = optional(number, 4096)
    admin_username           = optional(string, "azureadmin")
    admin_password           = optional(string) # do NOT commit — inject via secrets.auto.tfvars (gitignored)
    computer_name            = optional(string) # Windows NetBIOS name, max 15 chars, no dots
    enable_automatic_updates = optional(bool, false)
    enable_tpm               = optional(bool, false)
    secure_boot_enabled      = optional(bool, false)
  }))
  default = []
}

# ----------------------------------------------------------------------------
# Virtual Data Disks
# ----------------------------------------------------------------------------
variable "data_disks" {
  description = "List of virtual hard disks to deploy on the Azure Local cluster."
  type = list(object({
    name                  = string
    disk_size_gb          = number
    disk_file_format      = optional(string, "vhdx")
    dynamic               = optional(bool, true)
    hyper_v_generation    = optional(string)
    storage_path_id       = optional(string)
    logical_sector_bytes  = optional(number)
    physical_sector_bytes = optional(number)
    block_size_bytes      = optional(number)
    tags                  = optional(map(string), {})
  }))
  default = []
}

# ----------------------------------------------------------------------------
# AKS Arc Clusters
# ----------------------------------------------------------------------------
variable "aks_clusters" {
  description = "List of AKS Arc clusters to deploy on the Azure Local cluster."
  type = list(object({
    name                  = string
    logical_network_name  = optional(string) # name from var.networks (Terraform-managed)
    logical_network_id    = optional(string) # full resource ID (externally-managed)
    kubernetes_version    = optional(string) # null = cluster default
    control_plane_count   = optional(number, 1)
    control_plane_vm_size = optional(string, "Standard_A4_v2")
    control_plane_ip      = optional(string) # null = DHCP
    node_pools = list(object({
      name     = string
      count    = number
      vm_size  = optional(string, "Standard_A4_v2")
      os_type  = optional(string, "Linux")
      os_sku   = optional(string, "CBLMariner")
      max_pods = optional(number) # null = omitted, cluster assigns default
    }))
    pod_cidr               = optional(string, "10.244.0.0/16")
    load_balancer_count    = optional(number, 0)
    nfs_csi_driver_enabled = optional(bool, true)
    smb_csi_driver_enabled = optional(bool, true)
    tags                   = optional(map(string), {})
  }))
  default = []
}

# ----------------------------------------------------------------------------
# Linux Virtual Machines
# ----------------------------------------------------------------------------
variable "linux_vms" {
  description = "List of Linux VM instances to deploy on the Azure Local cluster. The module creates the Arc machine (HybridCompute/machines) and VM instance for each entry."
  type = list(object({
    name                    = string                     # used as the Arc machine name and map key
    image_id                = string                     # gallery image or marketplace gallery image resource ID
    storage_path_id         = optional(string)           # storageContainers resource ID for VM config files; null = cluster default
    network_interface_names = optional(list(string), []) # names from var.network_interfaces (Terraform-managed NICs)
    network_interface_ids   = optional(list(string), []) # full resource IDs for externally-managed NICs
    vm_size                 = optional(string, "Custom")
    cpu_count               = optional(number, 2)
    memory_mb               = optional(number, 4096)
    admin_username          = optional(string, "azureuser")
    admin_password          = string # do NOT commit — inject via secrets.auto.tfvars (gitignored)
    computer_name           = optional(string)
    enable_tpm              = optional(bool, false)
    secure_boot_enabled     = optional(bool, false)
  }))
  default = []
}
