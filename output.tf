output "vcn_id" {
  value =  module.network.vcn_id
}

output "private_node_subnet_id" {
  value =  module.network.private_node_subnet_id
}

output "public_api_subnet_id" {
  value =  module.network.public_api_subnet_id
}

output "public_svc_lb_subnet_id" {
  value =  module.network.public_svc_lb_subnet_id
}

output "cluster_kubernetes_versions" {
  value = module.oke.cluster_kubernetes_versions
}

output "node_pool_kubernetes_version" {
  value = module.oke.node_pool_kubernetes_version
}


