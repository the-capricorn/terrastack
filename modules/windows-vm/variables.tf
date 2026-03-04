variable "name" {
  type        = string
  description = "Name of the VM. Used as the Arc machine (Microsoft.HybridCompute/machines) name."
}

variable "location" {
  type        = string
  description = "Azure region in which to deploy the Arc machine (e.g., 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain the Arc machine."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "image_id" {
  type        = string
  description = "Resource ID of the gallery image or marketplace gallery image used to provision the OS disk."
}

variable "storage_path_id" {
  type        = string
  description = "Resource ID of the Microsoft.AzureStackHCI/storageContainers resource where VM configuration files are stored. If null, the cluster default storage path is used."
  default     = null
}

variable "network_interface_ids" {
  type        = list(string)
  description = "List of Microsoft.AzureStackHCI/networkInterfaces resource IDs to attach to this VM. At least one is required."

  validation {
    condition     = length(var.network_interface_ids) >= 1
    error_message = "At least one network_interface_id must be provided."
  }
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for the Windows VM. Must meet Azure password complexity requirements."
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the Windows VM."
  default     = "azureadmin"
}

variable "computer_name" {
  type        = string
  description = "Windows NetBIOS computer name (max 15 characters, no dots or spaces). If null, the platform assigns one. Must be set explicitly when the Arc machine name is an FQDN (e.g., host.domain.com)."
  default     = null

  validation {
    condition     = var.computer_name == null || (length(var.computer_name) <= 15 && can(regex("^[a-zA-Z0-9-]+$", var.computer_name)))
    error_message = "computer_name must be 1-15 alphanumeric characters or hyphens, with no dots or spaces."
  }
}

variable "vm_size" {
  type        = string
  description = "VM size to use. Set to 'Custom' and provide cpu_count and memory_mb for custom sizing, or use a predefined size (e.g., 'Standard_D4s_v3')."
  default     = "Custom"

  validation {
    condition = contains([
      "Custom",
      "Default",
      "Standard_A2_v2", "Standard_A4_v2",
      "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3",
      "Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_DS13_v2",
      "Standard_K8S_v1", "Standard_K8S2_v1", "Standard_K8S3_v1", "Standard_K8S4_v1", "Standard_K8S5_v1",
      "Standard_NK6", "Standard_NK12",
      "Standard_NV6", "Standard_NV12",
    ], var.vm_size)
    error_message = "vm_size must be 'Custom', 'Default', or one of the supported predefined sizes (e.g. 'Standard_D4s_v3')."
  }
}

variable "cpu_count" {
  type        = number
  description = "Number of virtual CPUs to assign. Used only when vm_size = 'Custom'."
  default     = 2

  validation {
    condition     = var.cpu_count >= 1
    error_message = "cpu_count must be at least 1."
  }
}

variable "memory_mb" {
  type        = number
  description = "Amount of RAM in megabytes. Used only when vm_size = 'Custom'."
  default     = 4096

  validation {
    condition     = var.memory_mb >= 512
    error_message = "memory_mb must be at least 512."
  }
}

variable "enable_automatic_updates" {
  type        = bool
  description = "Enable Windows automatic updates on the VM."
  default     = false
}

variable "enable_tpm" {
  type        = bool
  description = "Enable the virtual Trusted Platform Module (vTPM). Required for TrustedLaunch and Confidential VM security types."
  default     = false
}

variable "secure_boot_enabled" {
  type        = bool
  description = "Enable UEFI Secure Boot on the VM. Requires enable_tpm = true."
  default     = false

  validation {
    condition     = !var.secure_boot_enabled || var.enable_tpm
    error_message = "secure_boot_enabled requires enable_tpm to be true."
  }
}

# Note: Microsoft.AzureStackHCI/virtualMachineInstances is an extension resource
# attached to a Microsoft.HybridCompute/machines parent. It does not support
# top-level location or tags in its API schema — apply tags to the Arc machine instead.
