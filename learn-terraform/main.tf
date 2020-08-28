# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.20.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westus2"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "myTFSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "myTFPublicIP"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "myNIC"
  location                  = "westus2"
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "myTFVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"
  admin_username        = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  output "public_ip_address" {
    value = data.azurerm_public_ip.ip.ip_address
  }
}