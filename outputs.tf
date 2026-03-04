output "logical_network_ids" {
  description = "Map of logical network name to resource ID."
  value       = { for k, v in module.logical_network : k => v.logical_network_id }
}

output "subnet_ids" {
  description = "Map of logical network name to subnet resource ID."
  value       = { for k, v in module.logical_network : k => v.subnet_id }
}

output "network_interface_ids" {
  description = "Map of NIC name to resource ID."
  value       = { for k, v in module.network_interface : k => v.network_interface_id }
}

output "vm_instance_ids" {
  description = "Map of VM name to VM instance resource ID."
  value       = { for k, v in module.windows_vm : k => v.vm_instance_id }
}

output "linux_vm_instance_ids" {
  description = "Map of Linux VM name to VM instance resource ID."
  value       = { for k, v in module.linux_vm : k => v.vm_instance_id }
}

output "aks_cluster_ids" {
  description = "Map of AKS cluster name to connected cluster resource ID."
  value       = { for k, v in module.aks_cluster : k => v.connected_cluster_id }
}

output "aks_cluster_ssh_secret_names" {
  description = "Map of AKS cluster name to its node SSH private key secret name in Key Vault. Retrieve with: az keyvault secret show --vault-name <kv> --name <secret-name> --query value -o tsv"
  value       = { for k, v in azapi_resource.aks_cluster_ssh_secret : k => v.name }
}

output "linux_vm_ssh_secret_names" {
  description = "Map of Linux VM name to its SSH private key secret name in Key Vault. Retrieve with: az keyvault secret show --vault-name <kv> --name <secret-name> --query value -o tsv"
  value       = { for k, v in azapi_resource.linux_vm_ssh_secret : k => v.name }
}
