# Stage 5: a Linux client for SSH forwarding to the private database.
# Keep the client outside the Oracle-delegated subnet.
variable "client_ssh_source_cidr" {
  description = "Laptop public IPv4 with /32; update when your connection changes."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.client_ssh_source_cidr)) && endswith(var.client_ssh_source_cidr, "/32")
    error_message = "Supply a single IPv4 address followed by /32."
  }
}

variable "client_ssh_public_key_path" {
  type    = string
  default = "~/.ssh/azure-adbs-lab.pub"
}

variable "client_vm_size" {
  type    = string
  default = "Standard_F1als_v7"
}

resource "azurerm_subnet" "client" {
  name                 = "snet-adbs-client"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 1)]
}

resource "azurerm_network_security_group" "client" {
  name                = "nsg-adbs-client"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = azurerm_resource_group.lab.tags

  security_rule {
    name                       = "SSH-from-laptop"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.client_ssh_source_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "client" {
  name                = "pip-adbs-client"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = azurerm_resource_group.lab.tags
}

resource "azurerm_network_interface" "client" {
  name                = "nic-adbs-client"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = azurerm_resource_group.lab.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.client.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.client.id
  }
}

resource "azurerm_network_interface_security_group_association" "client" {
  network_interface_id      = azurerm_network_interface.client.id
  network_security_group_id = azurerm_network_security_group.client.id
}

resource "azurerm_linux_virtual_machine" "client" {
  name                            = "vm-adbs-client"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.client_vm_size
  disk_controller_type            = "NVMe"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.client.id]
  tags                            = azurerm_resource_group.lab.tags

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand(var.client_ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface_security_group_association.client]
}

output "client_public_ip" {
  value = azurerm_public_ip.client.ip_address
}

output "client_admin_username" {
  value = azurerm_linux_virtual_machine.client.admin_username
}


