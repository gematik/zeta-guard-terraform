locals {
  rg_name = "gematik-${var.project_short}-${var.stage}-stage"
}

resource "azurerm_resource_group" "showcase_rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.base_tags
}
