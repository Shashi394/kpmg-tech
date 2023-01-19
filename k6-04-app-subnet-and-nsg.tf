resource "azurerm_subnet" "appsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.app_subnet_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.app_subnet_address  
}

resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "${azurerm_subnet.appsubnet.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.app_nsg_rule_inbound]  
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}

locals {
  app_inbound_ports_map = {
    "100" : "80", 
    "110" : "443",
    "120" : "8080",
    "130" : "22"
  } 
}

resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
  for_each = local.app_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
}

resource "azurerm_network_interface" "kpmgappnic" {
  name                = "kpmgappNIC"    
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "kpmgappnic1"
    subnet_id                     = azurerm_subnet.appsubnet.id  
    private_ip_address_allocation = "Dynamic"        
  }    
}

resource "azurerm_linux_virtual_machine" "kpmg-app-vm" {
  name                  = "kpmg-app-vm"  
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.kpmgappnic.id]
  size                  = "Standard_DS1_v2"
    
  os_disk {
    name                 = "appOsDisk"    
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"    
    sku       = "18.04-LTS"
    version   = "latest"
  }  

}