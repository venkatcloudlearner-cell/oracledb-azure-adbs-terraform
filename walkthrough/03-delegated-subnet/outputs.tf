output "resource_group_name" {
  description = "Resource group created for the lab."
  value       = azurerm_resource_group.lab.name
}

output "location" {
  description = "Azure region used by the lab."
  value       = azurerm_resource_group.lab.location
}

output "virtual_network_name" {
  description = "Virtual network created for the lab."
  value       = azurerm_virtual_network.lab.name
}

output "oracle_subnet_name" {
  description = "Subnet reserved for the Oracle database."
  value       = azurerm_subnet.oracle.name
}

output "oracle_subnet_delegation" {
  description = "Service permitted to manage the Oracle subnet attachments."
  value       = azurerm_subnet.oracle.delegation[0].service_delegation[0].name
}
