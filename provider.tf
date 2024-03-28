provider "oci" {
   ### These information are needed only outside of OCI Terraform Stack Manager - Start
   ### So comment theses line if OCI Terraform Stack Manager
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
   ### These information are needed only outside of OCI Terraform Stack Manager - End
  region           = var.region
}
