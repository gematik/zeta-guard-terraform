locals {
  aks_name = "${var.project_short}-${var.stage}-aks"
}

data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.project_short}-${var.stage}-aks-vnet"
  location            = azurerm_resource_group.showcase_rg.location
  resource_group_name = azurerm_resource_group.showcase_rg.name
  address_space       = ["10.30.0.0/16"]
  tags                = local.base_tags
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "${var.project_short}-${var.stage}-aks-nodes"
  resource_group_name  = azurerm_virtual_network.aks_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.30.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_public_ip" "aks_ingress" {
  name                = "aks-ingress-pip"
  location            = azurerm_resource_group.showcase_rg.location
  resource_group_name = azurerm_resource_group.showcase_rg.name
  sku                 = "Standard"
  allocation_method   = "Static"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "aks_pip_netcontrib" {
  scope                = azurerm_public_ip.aks_ingress.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.default_cluster.identity[0].principal_id
}

resource "azurerm_kubernetes_cluster" "default_cluster" {
  name                = local.aks_name
  location            = azurerm_resource_group.showcase_rg.location
  resource_group_name = azurerm_resource_group.showcase_rg.name
  dns_prefix          = "${var.project_name}-${var.stage}"

  default_node_pool {
    name    = "default"
    vm_size = "Standard_D4s_v4" # other values? https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview

    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 5

    vnet_subnet_id = azurerm_subnet.aks_nodes.id

    upgrade_settings {
      max_surge                     = 1
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }

    # temporary_name_for_rotation = "nodepooltemp"
  }

  identity {
    type = "SystemAssigned"
  }

  # Azure AD + Azure RBAC (Ops)
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
    # admin_group_object_ids = [var.aks_admins_group_object_id] # optional
  }

  # Admin deaktivieren (kein --admin kubeconfig)
  local_account_disabled = false

  # API-Server-IP-Restriktion (nur wenn feste IP bekannt)
  # api_server_access_profile {
  #   authorized_ip_ranges = var.authorized_ip_ranges
  # }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.base_tags
}

resource "kubernetes_namespace" "demo_ui" {
  metadata { name = "demo-ui" }
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name      = "hello"
    namespace = kubernetes_namespace.demo_ui.metadata[0].name
    labels    = { app = "hello" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "hello" } }
    template {
      metadata { labels = { app = "hello" } }
      spec {
        container {
          name  = "hello"
          image = "nginxdemos/hello:0.4"
          port { container_port = 80 }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello" {
  metadata {
    name      = "hello"
    namespace = kubernetes_namespace.demo_ui.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-resource-group" = "gematik-zeta-dev-stage"
      "service.beta.kubernetes.io/azure-pip-name"                     = "aks-ingress-pip"
    }
    labels = { app = "hello" }
  }
  spec {
    type = "LoadBalancer"
    selector = { app = "hello" }
    port {
      port        = 8080
      target_port = 80
    }
  }
}
