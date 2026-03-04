variable "name" {
  type        = string
  description = "Name of the network interface. Must be 1-80 characters, starting and ending with an alphanumeric character."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]$|^[a-zA-Z0-9][-._a-zA-Z0-9]{0,78}[_a-zA-Z0-9]$", var.name))
    error_message = "name must be 1-80 characters, starting and ending with an alphanumeric character."
  }
}

variable "location" {
  type        = string
  description = "Azure region in which to deploy the network interface (e.g., 'westeurope')."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that will contain the network interface."
}

variable "custom_location_id" {
  type        = string
  description = "Full resource ID of the Custom Location associated with the Azure Local cluster."
}

variable "subnet_id" {
  type        = string
  description = "Logical network resource ID to attach this NIC to. Use the subnet_id output of the logical-network module. The HCI API field is named subnet.id but takes the logical network resource ID directly."
}

variable "private_ip_address" {
  type        = string
  description = "Optional static private IP address for the NIC. If null, the IP is assigned from the logical network's IP pool."
  default     = null
}

variable "dns_servers" {
  type        = list(string)
  description = "Optional list of DNS server IP addresses applied at the NIC level. Overrides logical network DNS settings."
  default     = []
}

variable "mac_address" {
  type        = string
  description = "Optional MAC address for the network interface. If null, one is auto-assigned by the platform."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the network interface resource."
  default     = {}
}
