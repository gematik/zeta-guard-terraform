output "resource_group_name" {
  value = azurerm_resource_group.state_resource_group.name
}

output "storage_account_name" {
  value = azurerm_storage_account.state_storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.state_container.name
}

output "backend_key_suggestion" {
  value = "showcase/aks/terraform.tfstate"
}

output "how_to_configure_backend" {
  value = <<EOT
Use these in showcase-stage/backend.hcl:
  resource_group_name  = "${azurerm_resource_group.state_resource_group.name}"
  storage_account_name = "${azurerm_storage_account.state_storage_account.name}"
  container_name       = "${azurerm_storage_container.state_container.name}"
  key                  = "showcase/aks/terraform.tfstate"
  use_azuread_auth     = true
EOT
}
