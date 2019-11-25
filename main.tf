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
