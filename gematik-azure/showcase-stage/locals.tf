locals {
  base_tags = {
    project     = var.project_name
    location    = var.location
    environment = var.stage
    owner       = "terraform"
  }
}
