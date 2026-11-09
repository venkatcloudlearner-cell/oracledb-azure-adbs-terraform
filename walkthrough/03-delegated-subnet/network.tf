# Stage 2: create the VNet before adding its delegated subnet.
resource "azurerm_virtual_network" "lab" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = [var.virtual_network_cidr]

  tags = azurerm_resource_group.lab.tags
}
