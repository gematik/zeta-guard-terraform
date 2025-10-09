locals {
  resource_group_name         = "rg-${var.project_short}-tfstate-${var.location}"
  storage_account_name_prefix = "sttfstate${var.location}"
  container_name              = "${var.project_short}-tfstate"

  base_tags = {
    project     = var.project_name
    location    = var.location
    environment = var.stage
    owner       = "terraform"
  }

  common_tags = merge(local.base_tags, var.extra_tags)
}

data "azurerm_client_config" "current" {

}

resource "azurerm_resource_group" "state_resource_group" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# globally-unique SA name
resource "random_string" "sa_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_account" "state_storage_account" {
  name                     = "${local.storage_account_name_prefix}${random_string.sa_suffix.result}"
  resource_group_name      = azurerm_resource_group.state_resource_group.name
  location                 = azurerm_resource_group.state_resource_group.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "state_container" {
  name                  = local.container_name
  storage_account_id    = azurerm_storage_account.state_storage_account.id
  container_access_type = "private"
}
resource "azurerm_storage_container" "state_container_ci" {
  name                  = "${local.container_name}-ci"
  storage_account_id    = azurerm_storage_account.state_storage_account.id
  container_access_type = "private"
}

data "azurerm_role_definition" "blob_contrib" {
  name  = "Storage Blob Data Contributor"
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azurerm_role_assignment" "current_blob_contrib" {
  count              = var.assign_current_principal ? 1 : 0
  scope              = azurerm_storage_account.state_storage_account.id
  role_definition_id = data.azurerm_role_definition.blob_contrib.role_definition_id
  principal_id       = data.azurerm_client_config.current.object_id
}
