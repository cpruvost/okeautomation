### OKE variables
variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

variable "vcn_id" {
    description = "The OCI VCN ocid"
    type        = string
}

variable "node_subnet_id" {
    description = "the Node Subnet Id"
    type        = string
}

variable "svc_lb_subnet_id" {
    description = "the Service Lb Subnet Id"
    type        = string
}

variable "api_subnet_id" {
    description = "the Api Subnet Id"
    type        = string
}

variable "kube_version" {
    description = "the Kube Version"
    type        = string
    default     = "v1.29.1"
}

variable "kube_type" {
    description = "the Kube Type basic or Enhanced"
    type        = string
    default     = "BASIC_CLUSTER"
}

variable "region" {
    description = "The OCI region"
    type        = string
}

variable "worker_node_number" {
    description = "The number of worker node"
    type        = number
}

variable "InstanceImageOCID" {
  type = map(string)

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1-amd   = "ocid1.image.oc1.phx.aaaaaaaadjnj3da72bztpxinmqpih62c2woscbp6l3wjn36by2cvmdhjub6a"
    us-ashburn-1-amd   = "ocid1.image.oc1.iad.aaaaaaaawufnve5jxze4xf7orejupw5iq3pms6cuadzjc7klojix6vmk42va"
    eu-frankfurt-1-amd = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaagbrvhganmn7awcr7plaaf5vhabmzhx763z5afiitswjwmzh7upna"
    uk-london-1-amd    = "ocid1.image.oc1.uk-london-1.aaaaaaaajwtut4l7fo3cvyraate6erdkyf2wdk5vpk6fp6ycng3dv2y3ymvq"
    // Oracle Image Linux 8 for Paris
    eu-paris-1-amd     = "ocid1.image.oc1.eu-paris-1.aaaaaaaaxecxqqa26qzs5vqhlf4wt5vcqboqtzdcbrgx3fm3f67wv4odsyla"
	// Oracle-Linux-Cloud-Developer-8.9-aarch64-2024.02.29-0
	eu-paris-1-arm = "ocid1.image.oc1.eu-paris-1.aaaaaaaaktow2mh2jaotmpfl7okouncbx7px3o6mlemrtiuv422upneskgwa"
  }
}

variable "ssh_public_key" {
    description = "the SSH Public Key To access OKE VM Node Pool"
    type        = string
}

variable "node_shape" {
    description = "The OCI Node Shape"
    type        = string
}

variable "type_shape" {
    description = "The OCI Type Shape (amd or intel)"
    type        = string
}

data "oci_identity_availability_domains" "ads" {
    #Required
    compartment_id = var.compartment_ocid
}	

resource "oci_containerengine_cluster" "oke_oci_containerengine_cluster" {
	cluster_pod_network_options {
		cni_type = "OCI_VCN_IP_NATIVE"
	}
	compartment_id = var.compartment_ocid
	endpoint_config {
		is_public_ip_enabled = "true"
		subnet_id = var.api_subnet_id
	}
	freeform_tags = {
		"OKEclusterName" = "MyOkeDemoCluster"
	}
	kubernetes_version = var.kube_version
	name = "MyOkeDemoCluster"
	options {
		admission_controller_options {
			is_pod_security_policy_enabled = "false"
		}
		persistent_volume_config {
			freeform_tags = {
				"OKEclusterName" = "MyOkeDemoCluster"
			}
		}
		service_lb_config {
			freeform_tags = {
				"OKEclusterName" = "MyOkeDemoCluster"
			}
		}
		service_lb_subnet_ids = [var.svc_lb_subnet_id]
	}
	type = var.kube_type
	vcn_id = var.vcn_id
}

resource "oci_containerengine_node_pool" "create_node_pool_1" {
	cluster_id = "${oci_containerengine_cluster.oke_oci_containerengine_cluster.id}"
	compartment_id = var.compartment_ocid
	freeform_tags = {
		"OKEnodePoolName" = "pool1"
	}
	initial_node_labels {
		key = "name"
		value = "pool1"
	}
	kubernetes_version = var.kube_version
	name = "pool1"
	node_config_details {
		freeform_tags = {
			"OKEnodePoolName" = "pool1"
		}
		node_pool_pod_network_option_details {
			cni_type = "OCI_VCN_IP_NATIVE"
            pod_subnet_ids = [var.node_subnet_id]
		}
		placement_configs {
			//availability_domain = "Vihs:EU-PARIS-1-AD-1"
			//Get First Avaibility Domain
			availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}"
			subnet_id = var.node_subnet_id
		}
		size = var.worker_node_number
	}
	node_eviction_node_pool_settings {
		eviction_grace_duration = "PT60M"
	}
	//node_shape = "VM.Standard.E4.Flex"
	node_shape = var.node_shape
	node_shape_config {
		memory_in_gbs = "16"
		ocpus = "2"
	}
	node_source_details {
		//image_id = "ocid1.image.oc1.eu-paris-1.aaaaaaaaxecxqqa26qzs5vqhlf4wt5vcqboqtzdcbrgx3fm3f67wv4odsyla"
        image_id = var.InstanceImageOCID["${var.region}-${var.type_shape}"]
		source_type = "IMAGE"
	}
	ssh_public_key = var.ssh_public_key
}