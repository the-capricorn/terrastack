variable "name" {
  type        = string
  description = "Name of the logical network. Must be 2-64 characters, starting and ending with an alphanumeric character."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]$|^[a-zA-Z0-9][-._a-zA-Z0-9]{0,62}[_a-zA-Z0-9]$", var.name))
    error_message = "name must be 2-64 characters and match the pattern ^[a-zA-Z0-9]$|^[a-zA-Z0-9][-._a-zA-Z0-9]{0,62}[_a-zA-Z0-9]$."
  }
}

variable "location" {
  type        = string
  description = "Azure region in which to deploy the logical network (e.g., 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain the logical network."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "vm_switch_name" {
  type        = string
  description = "Name of the VM switch on the Azure Local cluster to bind to this logical network."
}

variable "address_space" {
  type        = list(string)
  description = "Overall CIDR address space for the logical network (e.g., [\"10.0.0.0/16\"]). Must contain at least one prefix."

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR prefix."
  }
}

variable "dns_servers" {
  type        = list(string)
  description = "Optional list of DNS server IP addresses applied at the logical network level. Subnet-level DHCP options override these."
  default     = []
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet within the logical network. Must be 2-64 characters, starting and ending with an alphanumeric character."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]$|^[a-zA-Z0-9][-._a-zA-Z0-9]{0,62}[_a-zA-Z0-9]$", var.subnet_name))
    error_message = "subnet_name must be 2-64 characters, starting and ending with an alphanumeric character."
  }
}

variable "ip_allocation_method" {
  type        = string
  description = "IP allocation method for the subnet ('Dynamic' or 'Static')."
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.ip_allocation_method)
    error_message = "ip_allocation_method must be 'Dynamic' or 'Static'."
  }
}

variable "vlan" {
  type        = number
  description = "Optional VLAN ID for the subnet (1-4094). Set to null to disable VLAN tagging."
  default     = null

  validation {
    condition     = var.vlan == null || (var.vlan >= 1 && var.vlan <= 4094)
    error_message = "vlan must be between 1 and 4094, or null to disable VLAN tagging."
  }
}

variable "ip_pool_start" {
  type        = string
  description = "First IP address of the static IP pool (e.g. \"10.10.10.10\"). Must be set together with ip_pool_end."
  default     = null
}

variable "ip_pool_end" {
  type        = string
  description = "Last IP address of the static IP pool (e.g. \"10.10.10.250\"). Must be set together with ip_pool_start."
  default     = null

  validation {
    condition     = (var.ip_pool_start == null) == (var.ip_pool_end == null)
    error_message = "ip_pool_start and ip_pool_end must both be set or both be null."
  }
}

variable "default_gateway" {
  type        = string
  description = "Optional default gateway IP address. If set, a 0.0.0.0/0 route is added to the subnet's route table."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the logical network resource."
  default     = {}
}
