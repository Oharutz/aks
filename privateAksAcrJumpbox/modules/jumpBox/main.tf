resource "azurerm_virtual_machine" "jumpbox" {
  name                = "jumpbox-vm"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_name
  network_interface_ids = [
    azurerm_network_interface.jumpbox_nic.id
  ]
  vm_size             = "Standard_B2ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }
  os_profile_linux_config {
  disable_password_authentication = false
  ssh_keys {
    path     = "/home/azureuser/.ssh/authorized_keys"
    key_data = file("~/.ssh/id_rsa.pub")
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
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}