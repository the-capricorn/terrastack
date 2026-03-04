variable "name" {
  type        = string
  description = "Name of the virtual hard disk resource."
}

variable "location" {
  type        = string
  description = "Azure region in which to deploy the virtual hard disk (e.g., 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain the virtual hard disk."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the virtual hard disk in gigabytes."

  validation {
    condition     = var.disk_size_gb >= 1
    error_message = "disk_size_gb must be at least 1."
  }
}

variable "disk_file_format" {
  type        = string
  description = "File format of the virtual hard disk. Must be 'vhdx' or 'vhd'."
  default     = "vhdx"

  validation {
    condition     = contains(["vhdx", "vhd"], var.disk_file_format)
    error_message = "disk_file_format must be 'vhdx' or 'vhd'."
  }
}

variable "dynamic" {
  type        = bool
  description = "Whether to create a dynamically expanding disk (true) or a fixed-size disk (false)."
  default     = true
}

variable "hyper_v_generation" {
  type        = string
  description = "Hyper-V generation of the disk. Must be 'V1' or 'V2'. If null, the cluster default is used."
  default     = null

  validation {
    condition     = var.hyper_v_generation == null || contains(["V1", "V2"], var.hyper_v_generation)
    error_message = "hyper_v_generation must be 'V1' or 'V2'."
  }
}

variable "storage_path_id" {
  type        = string
  description = "Resource ID of the Microsoft.AzureStackHCI/storageContainers resource where the disk file is stored. If null, the cluster default storage path is used."
  default     = null
}

variable "logical_sector_bytes" {
  type        = number
  description = "Logical sector size in bytes. Common values: 512, 4096. If null, the cluster default is used."
  default     = null

  validation {
    condition     = var.logical_sector_bytes == null || contains([512, 4096], var.logical_sector_bytes)
    error_message = "logical_sector_bytes must be 512 or 4096."
  }
}

variable "physical_sector_bytes" {
  type        = number
  description = "Physical sector size in bytes. Common values: 512, 4096. If null, the cluster default is used."
  default     = null

  validation {
    condition     = var.physical_sector_bytes == null || contains([512, 4096], var.physical_sector_bytes)
    error_message = "physical_sector_bytes must be 512 or 4096."
  }
}

variable "block_size_bytes" {
  type        = number
  description = "Block size in bytes for the virtual hard disk. If null, the cluster default is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the virtual hard disk resource."
  default     = {}
}
