output "vcn_id" {
  value =  oci_core_vcn.oke_oci_core_vcn.id
}

output "private_node_subnet_id" {
  value =  oci_core_subnet.node_subnet.id
}

output "public_api_subnet_id" {
  value =  oci_core_subnet.kubernetes_api_endpoint_subnet.id
}

output "public_svc_lb_subnet_id" {
  value =  oci_core_subnet.service_lb_subnet.id
}

