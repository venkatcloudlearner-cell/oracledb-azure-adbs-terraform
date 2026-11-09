# Stage 3: reserve a subnet exclusively for Oracle Database@Azure.
# The advanced networking features were registered before this subnet is created.
resource "azurerm_subnet" "oracle" {
  name                 = var.oracle_subnet_name
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.oracle_subnet_cidr]

  delegation {
    name = "oracle-database-delegation"

    service_delegation {
      name = "Oracle.Database/networkAttachments"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
