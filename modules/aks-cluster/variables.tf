variable "name" {
  type        = string
  description = "Name of the AKS Arc cluster. Also used as the Arc connected cluster (Microsoft.Kubernetes/connectedClusters) resource name."
}

variable "location" {
  type        = string
  description = "Azure region in which to register the Arc connected cluster (e.g., 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain the connected cluster resource."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "logical_network_id" {
  type        = string
  description = "Resource ID of the Microsoft.AzureStackHCI/logicalNetworks resource used for cluster node networking."
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key installed on all cluster nodes for the admin user. PEM format."

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "ssh_public_key must be a non-empty string."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to deploy (e.g. '1.28.5'). Set to null to use the cluster default."
  default     = null
}

variable "control_plane_count" {
  type        = number
  description = "Number of control plane nodes. Must be an odd number: 1, 3, or 5."
  default     = 1

  validation {
    condition     = contains([1, 3, 5], var.control_plane_count)
    error_message = "control_plane_count must be 1, 3, or 5."
  }
}

variable "control_plane_vm_size" {
  type        = string
  description = "VM size for control plane nodes (e.g. 'Standard_A4_v2')."
  default     = "Standard_A4_v2"
}

variable "control_plane_ip" {
  type        = string
  description = "Static IP address for the control plane endpoint. Set to null to use DHCP assignment."
  default     = null
}

variable "node_pools" {
  type = list(object({
    name     = string
    count    = number
    vm_size  = optional(string, "Standard_A4_v2")
    os_type  = optional(string, "Linux")
    os_sku   = optional(string, "CBLMariner")
    max_pods = optional(number) # null = omitted, cluster assigns default
  }))
  description = "List of node pools. The first entry becomes the initial node pool (agentPoolProfiles). Additional entries are created as separate agentPools child resources."

  validation {
    condition     = length(var.node_pools) >= 1
    error_message = "At least one node pool must be defined."
  }
}

variable "pod_cidr" {
  type        = string
  description = "CIDR range for pod IP addresses."
  default     = "10.244.0.0/16"
}

variable "load_balancer_count" {
  type        = number
  description = "Number of dedicated HA Proxy load balancer VMs. Use 0 for no dedicated load balancer."
  default     = 0

  validation {
    condition     = var.load_balancer_count >= 0
    error_message = "load_balancer_count must be 0 or a positive integer."
  }
}

variable "nfs_csi_driver_enabled" {
  type        = bool
  description = "Enable the NFS CSI driver on the cluster."
  default     = true
}

variable "smb_csi_driver_enabled" {
  type        = bool
  description = "Enable the SMB CSI driver on the cluster."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Arc connected cluster resource."
  default     = {}
}
