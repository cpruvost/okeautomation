output "cluster_kubernetes_versions" {
  value = oci_containerengine_cluster.oke_oci_containerengine_cluster.kubernetes_version
}

output "node_pool_kubernetes_version" {
  value = oci_containerengine_node_pool.create_node_pool_1.kubernetes_version
}