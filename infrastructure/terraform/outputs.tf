output "resource_group_name" {
  description = "Name of the V2 resource group."
  value       = azurerm_resource_group.v2.name
}

output "virtual_network_name" {
  description = "Name of the V2 virtual network."
  value       = azurerm_virtual_network.v2.name
}

output "subnet_name" {
  description = "Name of the V2 subnet."
  value       = azurerm_subnet.v2.name
}

output "network_security_group_name" {
  description = "Name of the V2 network security group."
  value       = azurerm_network_security_group.v2.name
}

output "public_ip_address" {
  description = "Public IP address assigned to the V2 Linux VM."
  value       = azurerm_public_ip.v2.ip_address
}

output "virtual_machine_name" {
  description = "Name of the V2 Linux virtual machine."
  value       = azurerm_linux_virtual_machine.v2.name
}

output "ssh_connection_command" {
  description = "SSH command for connecting to the V2 Linux VM."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.v2.ip_address}"
}
