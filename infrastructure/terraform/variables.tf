variable "project_name" {
  description = "Name of the V2 project."
  type        = string
  default     = "v2-identity-access-security"
}

variable "location" {
  description = "Azure region where V2 resources will be deployed."
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Name of the V2 Azure resource group."
  type        = string
  default     = "rg-v2-identity-access-security"
}

variable "vnet_address_space" {
  description = "Address space for the V2 virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the V2 subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "vm_name" {
  description = "Name of the V2 Linux virtual machine."
  type        = string
  default     = "vm-v2-secure-linux"
}

variable "vm_size" {
  description = "Azure VM size for the V2 environment."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "admin_username" {
  description = "Administrative username for the Linux VM."
  type        = string
  default     = "azureadmin"
}
variable "admin_ssh_public_key" {
  description = "SSH public key used to access the Linux VM."
  type        = string
  sensitive   = true
}
variable "admin_source_ip" {
  description = "Public IPv4 address allowed to access the Linux VM over SSH."
  type        = string
}