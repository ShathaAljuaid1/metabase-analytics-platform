terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "metabase" {
  name     = "rg-metabase-project"
  location = "westus2"
}

resource "azurerm_virtual_network" "metabase" {
  name                = "metabase-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name
}

resource "azurerm_subnet" "metabase" {
  name                 = "metabase-subnet"
  resource_group_name  = azurerm_resource_group.metabase.name
  virtual_network_name = azurerm_virtual_network.metabase.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "metabase" {
  name                = "metabase-nsg"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.metabase.name
  network_security_group_name = azurerm_network_security_group.metabase.name
}

resource "azurerm_network_security_rule" "metabase" {
  name                        = "allow-metabase"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.metabase.name
  network_security_group_name = azurerm_network_security_group.metabase.name
}

resource "azurerm_public_ip" "metabase" {
  name                = "metabase-public-ip"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "metabase" {
  name                = "metabase-nic"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.metabase.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.metabase.id
  }
}

resource "azurerm_network_interface_security_group_association" "metabase" {
  network_interface_id      = azurerm_network_interface.metabase.id
  network_security_group_id = azurerm_network_security_group.metabase.id
}

resource "azurerm_linux_virtual_machine" "metabase" {
  name                = "metabase-vm"
  resource_group_name = azurerm_resource_group.metabase.name
  location            = azurerm_resource_group.metabase.location
  size                = "Standard_B2als_v2"
  admin_username      = "azureuser"

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.metabase.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_ed25519.pub")
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
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "metabase" {
  name                = "kv-metabase-project"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                   = "standard"
  rbac_authorization_enabled = true

  soft_delete_retention_days = 90
  purge_protection_enabled   = false
}

resource "azurerm_role_assignment" "vm_key_vault_secrets" {
  scope                = azurerm_key_vault.metabase.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.metabase.identity[0].principal_id
}