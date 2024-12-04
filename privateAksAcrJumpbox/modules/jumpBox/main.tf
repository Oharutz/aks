resource "azurerm_virtual_machine" "jumpbox" {
  name                = "jumpbox-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  network_interface_ids = [
    azurerm_network_interface.jumpbox_nic.id
  ]
  vm_size             = "Standard_B2ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "azureuser"
    admin_password = var.jumpbox_password
  }
}

resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}