### VCN variables
# Not usefull in theory but keep it to remind
# variable "tenancy_ocid" {
#     description = "The OCI Tenancy ocid"
#     type        = string
# }

variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

# Not usefull in theory but keep it to remind
# data "oci_identity_availability_domain" "ad" {
#   compartment_id = var.tenancy_ocid
#   ad_number      = 1
# }
variable "region" {
    description = "The OCI region"
    type        = string
}

variable "RouteRuleDestination" {
  type = map(string)

  default = {
    eu-paris-1    = "all-cdg-services-in-oracle-services-network"
	uk-london-1   = "all-lhr-services-in-oracle-services-network"
  }
}

data "oci_core_services" "test_services" {
}

resource "oci_core_vcn" "oke_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
	display_name = "OkeVCN"
	dns_label = "okevcn"
}

resource "oci_core_internet_gateway" "oke_oci_core_internet_gateway" {
	compartment_id = var.compartment_ocid
	display_name = "Internet Gateway OkeVCN"
	enabled = "true"
	vcn_id = oci_core_vcn.oke_oci_core_vcn.id
}

resource "oci_core_nat_gateway" "oke_oci_core_nat_gateway" {
	compartment_id = var.compartment_ocid
	display_name = "Nat Gateway OkeVCN"
	vcn_id = oci_core_vcn.oke_oci_core_vcn.id
}

resource "oci_core_service_gateway" "oke_oci_core_service_gateway" {
	compartment_id = var.compartment_ocid
	display_name = "Service Gateway OkeVCN"
	services {
		service_id = data.oci_core_services.test_services.services.0.id
	}
	vcn_id = oci_core_vcn.oke_oci_core_vcn.id
}

resource "oci_core_route_table" "oke_oci_core_route_table" {
	compartment_id = var.compartment_ocid
	display_name = "oke-private-routetable-MyOkeDemoCluster"
	route_rules {
		description = "traffic to the internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = oci_core_nat_gateway.oke_oci_core_nat_gateway.id
	}
	route_rules {
		description = "traffic to OCI services"
		//destination = "all-cdg-services-in-oracle-services-network"
		destination = var.RouteRuleDestination["${var.region}"]
		destination_type = "SERVICE_CIDR_BLOCK"
		network_entity_id = oci_core_service_gateway.oke_oci_core_service_gateway.id
	}
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_subnet" "service_lb_subnet" {
	cidr_block = "10.0.20.0/24"
	compartment_id = var.compartment_ocid
	display_name = "Oke Service Lb Subnet"
	dns_label = "okeservicelbsub"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.oke_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_vcn.oke_oci_core_vcn.default_security_list_id}"]
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_subnet" "node_subnet" {
	cidr_block = "10.0.10.0/24"
	compartment_id = var.compartment_ocid
	display_name = "Oke Node Subnet"
	dns_label = "okenodesub"
	prohibit_public_ip_on_vnic = "true"
	route_table_id = oci_core_route_table.oke_oci_core_route_table.id
	security_list_ids = ["${oci_core_security_list.node_sec_list.id}"]
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
	cidr_block = "10.0.0.0/28"
	compartment_id = var.compartment_ocid
	display_name = "Oke Api Subnet"
	dns_label = "okeapisub"
	prohibit_public_ip_on_vnic = "false"
	route_table_id = "${oci_core_default_route_table.oke_oci_core_default_route_table.id}"
	security_list_ids = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_default_route_table" "oke_oci_core_default_route_table" {
	display_name = "oke-public-routetable-MyOkeDemoCluster"
	route_rules {
		description = "traffic to/from internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.oke_oci_core_internet_gateway.id}"
	}
	manage_default_resource_id = "${oci_core_vcn.oke_oci_core_vcn.default_route_table_id}"
}

resource "oci_core_security_list" "service_lb_sec_list" {
	compartment_id = var.compartment_ocid
	display_name = "oke-svclbseclist"
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_security_list" "node_sec_list" {
	compartment_id = var.compartment_ocid
	display_name = "oke-nodeseclist"
	egress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	egress_security_rules {
		description = "Access to Kubernetes API Endpoint"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Kubernetes worker to control plane communication"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.0.0/28"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
		//For london --> all-lhr-services-in-oracle-services-network (oci network service list --region uk-london-1)
		//destination = "all-cdg-services-in-oracle-services-network"
		destination = var.RouteRuleDestination["${var.region}"]
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "ICMP Access from Kubernetes Control Plane"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Worker Nodes access to Internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		protocol = "all"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "TCP access from Kubernetes Control Plane"
		protocol = "6"
		source = "10.0.0.0/28"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Inbound SSH traffic to worker nodes"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}


	
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
	compartment_id = var.compartment_ocid
	display_name = "oke-k8sApiEndpoint"
	egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		//destination = "all-cdg-services-in-oracle-services-network"
		destination = var.RouteRuleDestination["${var.region}"]
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = "10.0.10.0/24"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "10.0.10.0/24"
		stateless = "false"
	}
	vcn_id = "${oci_core_vcn.oke_oci_core_vcn.id}"
}

