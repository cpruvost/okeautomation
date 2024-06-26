### These information are needed only outside of OCI Terraform Stack Manager - Start
### So comment these lines with OCI Terraform Stack Manager
# variable "tenancy_ocid" {
#     description = "The OCI Tenancy ocid"
#     type        = string
# }

# variable "user_ocid" {
#     description = "The OCI User ocid"
#     type        = string
# }

# variable "fingerprint" {
#     description = "The Fingerprint of the OCI API Key"
#     type        = string
# }

# variable "private_key_path" {
#     description = "The Path of the OCI API Key"
#     type        = string
# }
### These information are needed only outside of OCI Terraform Stack Manager - End

variable "ssh_public_key" {
    description = "the SSH Public Key To access Oke VM"
    type        = string
}

variable "region" {
    description = "The OCI region"
    type        = string
}

variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

variable "worker_node_number" {
    description = "The number of worker node"
    type        = number
}

variable "node_shape" {
    description = "The OCI Node Shape"
    type        = string
}

variable "type_shape" {
    description = "The OCI Type Shape (amd or intel)"
    type        = string
}