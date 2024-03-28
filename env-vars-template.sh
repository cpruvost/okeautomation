### Authentication details
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_fingerprint="38:4b:39:f0:03:39:xxxxxxxxxxxxxxxxxxxxxxxxx"
#For the API Key
export TF_VAR_private_key_path="./Travail/Travail2023/xxxxxxxxxxxxxxx/xxxxxxxxxxxxxKey.pem"

### SSH Key Oke VM
export TF_VAR_ssh_public_key = $(cat ./Travail/Travail2023/xxxxxxxxxxxxxxx/xxxxxxxxxxxxxKey.pub)

### Compartment
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxx"

### Region
export TF_VAR_region="eu-paris-1"


