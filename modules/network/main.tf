resource "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = [var.virtual_network_address_prefix]

  subnet {
    name           = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix # Kubernetes Subnet Address prefix
  }

  subnet {
    name           = "appgwsubnet" # REQUIRED to be hardcoded to this name
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  tags = var.network_tags
}

data "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "appgw" {
  name                 = "appgwsubnet" # REQUIRED to be hardcoded to this name
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

# Public Ip
resource "azurerm_public_ip" "aks" {
  name                         = "publicIp1"
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags = var.public_ip_tags
}
