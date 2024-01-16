output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}
