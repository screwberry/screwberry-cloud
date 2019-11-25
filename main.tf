variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable resource_group_name {}
variable resource_group_location {}
variable "resource_prefix" {}
variable "environment" {}
variable "terraform_script_version" {}

provider "azurerm" {
    version         = "1.36.1"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
    subscription_id = "${var.subscription_id}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

# IoT Hub resources

resource "azurerm_storage_account" "sta" {
  name                     = "${var.resource_prefix}storage"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.resource_prefix}-container"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.sta.name}"
  container_access_type = "private"
}

resource "azurerm_iothub" "iothub" {
  name                = "${var.resource_prefix}-iothub"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    name     = "F1"
    tier     = "Free"
    capacity = "1"
  }

  fallback_route {
    endpoint_names = ["events"]
    enabled = true
  }

  tags = {
    project     = "screwberry"
    environment = "${var.environment}"
  }
}

resource "azurerm_iothub_consumer_group" "cg" {
  name                   = "unity"
  iothub_name            = "${azurerm_iothub.iothub.name}"
  eventhub_endpoint_name = "events"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
}

# Virtual machine resources
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                    = "${var.resource_prefix}-pip"
  location                = "${azurerm_resource_group.rg.location}"
  resource_group_name     = "${azurerm_resource_group.rg.name}"
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    project     = "screwberry"
    environment = "${var.environment}"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.resource_prefix}-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.resource_prefix}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.resource_prefix}-vm"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_B1S"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.resource_prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    project     = "screwberry"
    environment = "${var.environment}"
  }
}

resource "azurerm_virtual_machine_extension" "ext" {
  name                 = "docker-grafana"
  location             = "${azurerm_resource_group.rg.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
  "fileUris": ["https://raw.githubusercontent.com/screwberry/screwberry-cloud/master/installAll.sh"],
    "commandToExecute": "sh installAll.sh"
  }
SETTINGS

  tags = {
    project     = "screwberry"
    environment = "${var.environment}"
  }
}