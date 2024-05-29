terraform {
  required_providers {
    oci = {
      version = "~> 5.35.0"
    }
  }

  #OCI Terraform Stack does not support last version
  #for outside OCI Terraform Stack
  #required_version = "~> 1.7.3"
  #for OCI Terraform Stack
  required_version = "~> 1.2.9"
}

module "network" {
  source  = "./modules/network"

  compartment_ocid  = var.compartment_ocid
  region = var.region
  # Not usefull in theory but keep it to remind
  #tenancy_ocid = var.tenancy_ocid
}

module "oke" {
  source  = "./modules/oke"

  compartment_ocid  = var.compartment_ocid
  region = var.region

  vcn_id = module.network.vcn_id
  node_subnet_id = module.network.private_node_subnet_id
  svc_lb_subnet_id = module.network.public_svc_lb_subnet_id
  api_subnet_id = module.network.public_api_subnet_id

  ssh_public_key = var.ssh_public_key
  worker_node_number = var.worker_node_number
  node_shape = var.node_shape
  type_shape = var.type_shape
}

