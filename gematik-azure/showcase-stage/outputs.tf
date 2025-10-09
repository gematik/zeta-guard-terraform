output "resource_group" {
  value = azurerm_resource_group.showcase_rg.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.default_cluster.name
}

# use az CLI to retrieve kubeconfig; raw kubeconfig is sensitive and omitted here. -> az aks get-credentials -g $(terraform output -raw resource_group) -n $(terraform output -raw aks_name) --overwrite-existing
