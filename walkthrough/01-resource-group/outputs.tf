output "resource_group_name" {
  description = "Resource group created for the lab."
  value       = azurerm_resource_group.lab.name
}

output "location" {
  description = "Azure region used by the lab."
  value       = azurerm_resource_group.lab.location
}
