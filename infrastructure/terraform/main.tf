resource "azurerm_resource_group" "v2" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = var.project_name
    environment = "lab"
    version     = "v2"
  }
}

resource "azurerm_virtual_network" "v2" {
  name                = "vnet-v2-identity-security"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.v2.location
  resource_group_name = azurerm_resource_group.v2.name

  tags = {
    project = var.project_name
  }
}

resource "azurerm_subnet" "v2" {
  name                 = "snet-v2-web"
  resource_group_name  = azurerm_resource_group.v2.name
  virtual_network_name = azurerm_virtual_network.v2.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "v2" {
  subnet_id                 = azurerm_subnet.v2.id
  network_security_group_id = azurerm_network_security_group.v2.id
}

resource "azurerm_network_security_group" "v2" {
  name                = "nsg-v2-secure-web"
  location            = azurerm_resource_group.v2.location
  resource_group_name = azurerm_resource_group.v2.name

  security_rule {
    name                       = "Allow-SSH-From-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_ip
    destination_address_prefix = "*"
  }

  tags = {
    project = var.project_name
  }
}

resource "azurerm_public_ip" "v2" {
  name                = "pip-v2-secure-web"
  location            = azurerm_resource_group.v2.location
  resource_group_name = azurerm_resource_group.v2.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    project = var.project_name
  }
}

resource "azurerm_network_interface" "v2" {
  name                = "nic-v2-secure-web"
  location            = azurerm_resource_group.v2.location
  resource_group_name = azurerm_resource_group.v2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.v2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.v2.id
  }

  tags = {
    project = var.project_name
  }
}

resource "azurerm_network_interface_security_group_association" "v2" {
  network_interface_id      = azurerm_network_interface.v2.id
  network_security_group_id = azurerm_network_security_group.v2.id
}

resource "azurerm_linux_virtual_machine" "v2" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.v2.name
  location            = azurerm_resource_group.v2.location
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.v2.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    project     = var.project_name
    environment = "lab"
    version     = "v2"
  }
}
