locals {
  networks_map     = { for n in var.networks : n.name => n }
  nics_map         = { for nic in var.network_interfaces : nic.name => nic }
  vms_map          = { for vm in var.virtual_machines : vm.name => vm }
  linux_vms_map    = { for vm in var.linux_vms : vm.name => vm }
  data_disks_map   = { for d in var.data_disks : d.name => d }
  aks_clusters_map = { for c in var.aks_clusters : c.name => c }
}

module "logical_network" {
  source   = "./modules/logical-network"
  for_each = local.networks_map

  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  custom_location_id   = var.custom_location_id
  vm_switch_name       = var.vm_switch_name
  address_space        = each.value.address_space
  dns_servers          = each.value.dns_servers
  subnet_name          = each.value.subnet_name != null ? each.value.subnet_name : "snet-${each.key}"
  ip_allocation_method = each.value.ip_allocation_method
  vlan                 = each.value.vlan
  ip_pool_start        = each.value.ip_pool_start
  ip_pool_end          = each.value.ip_pool_end
  default_gateway      = each.value.default_gateway
  tags                 = merge(var.tags, each.value.tags)
}

module "network_interface" {
  source   = "./modules/network-interface"
  for_each = local.nics_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_location_id  = var.custom_location_id
  subnet_id           = module.logical_network[each.value.logical_network_name].subnet_id
  private_ip_address  = each.value.private_ip_address
  dns_servers         = each.value.dns_servers
  mac_address         = each.value.mac_address
  tags                = merge(var.tags, each.value.tags)
}

module "windows_vm" {
  source   = "./modules/windows-vm"
  for_each = local.vms_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_location_id  = var.custom_location_id

  image_id        = each.value.image_id
  storage_path_id = each.value.storage_path_id

  network_interface_ids = concat(
    [for nic_name in each.value.network_interface_names :
    module.network_interface[nic_name].network_interface_id],
    each.value.network_interface_ids
  )

  vm_size   = each.value.vm_size
  cpu_count = each.value.cpu_count
  memory_mb = each.value.memory_mb

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  computer_name  = each.value.computer_name

  enable_automatic_updates = each.value.enable_automatic_updates
  enable_tpm               = each.value.enable_tpm
  secure_boot_enabled      = each.value.secure_boot_enabled
}

module "data_disk" {
  source   = "./modules/virtual-data-disk"
  for_each = local.data_disks_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_location_id  = var.custom_location_id

  disk_size_gb          = each.value.disk_size_gb
  disk_file_format      = each.value.disk_file_format
  dynamic               = each.value.dynamic
  hyper_v_generation    = each.value.hyper_v_generation
  storage_path_id       = each.value.storage_path_id
  logical_sector_bytes  = each.value.logical_sector_bytes
  physical_sector_bytes = each.value.physical_sector_bytes
  block_size_bytes      = each.value.block_size_bytes
  tags                  = merge(var.tags, each.value.tags)
}

resource "tls_private_key" "linux_admin" {
  for_each  = local.linux_vms_map
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the private key in Key Vault — one secret per Linux VM.
# Secret name: "ssh-<vm-name>" with dots replaced by hyphens (KV names allow only letters, numbers, hyphens).
# Deployer retrieves the key from Key Vault directly using their own KV RBAC permissions.
resource "azapi_resource" "linux_vm_ssh_secret" {
  for_each  = local.linux_vms_map
  type      = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  name      = "ssh-${replace(each.key, ".", "-")}"
  parent_id = var.key_vault_id

  body = {
    properties = {
      value = tls_private_key.linux_admin[each.key].private_key_openssh
    }
  }
}

resource "tls_private_key" "aks_node" {
  for_each  = local.aks_clusters_map
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the node SSH private key in Key Vault — one secret per AKS cluster.
# Deployer retrieves with: az keyvault secret show --vault-name <kv> --name <secret> --query value -o tsv
resource "azapi_resource" "aks_cluster_ssh_secret" {
  for_each  = local.aks_clusters_map
  type      = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  name      = "ssh-aks-${replace(each.key, ".", "-")}"
  parent_id = var.key_vault_id

  body = {
    properties = {
      value = tls_private_key.aks_node[each.key].private_key_openssh
    }
  }
}

module "aks_cluster" {
  source   = "./modules/aks-cluster"
  for_each = local.aks_clusters_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_location_id  = var.custom_location_id

  logical_network_id = each.value.logical_network_id != null ? (
    each.value.logical_network_id
  ) : module.logical_network[each.value.logical_network_name].logical_network_id

  ssh_public_key = tls_private_key.aks_node[each.key].public_key_openssh

  kubernetes_version    = each.value.kubernetes_version
  control_plane_count   = each.value.control_plane_count
  control_plane_vm_size = each.value.control_plane_vm_size
  control_plane_ip      = each.value.control_plane_ip

  node_pools             = each.value.node_pools
  pod_cidr               = each.value.pod_cidr
  load_balancer_count    = each.value.load_balancer_count
  nfs_csi_driver_enabled = each.value.nfs_csi_driver_enabled
  smb_csi_driver_enabled = each.value.smb_csi_driver_enabled

  tags = merge(var.tags, each.value.tags)
}

module "linux_vm" {
  source   = "./modules/linux-vm"
  for_each = local.linux_vms_map

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_location_id  = var.custom_location_id

  image_id        = each.value.image_id
  storage_path_id = each.value.storage_path_id

  network_interface_ids = concat(
    [for nic_name in each.value.network_interface_names :
    module.network_interface[nic_name].network_interface_id],
    each.value.network_interface_ids
  )

  vm_size   = each.value.vm_size
  cpu_count = each.value.cpu_count
  memory_mb = each.value.memory_mb

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  ssh_public_key = tls_private_key.linux_admin[each.key].public_key_openssh
  computer_name  = each.value.computer_name

  enable_tpm          = each.value.enable_tpm
  secure_boot_enabled = each.value.secure_boot_enabled
}
