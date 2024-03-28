# Terraform Automation on Oracle Cloud : Create an OKE with Managed nodes in a VCN where you can choose IP cidr Blocks

This project has been designed to run with Terraform alone on your laptop for ex. If you want to run it on OCI Stack Resource Manager then you need to modify some files. Look at comments in variables.tf, main.tf, and provider.tf
Note that there are 2 modules (one for the network and one for the OKE). This stack was created from a reverse engineering of the OKE Wizard. It is more simple to begin from an example :o).
Reading the network files you can understand the requisites for the network part (there are 3 subnets in the VCN and you can have a look to the security rules needed by OKE). 

## Prerequisites

You must know terraform a little
Clone the github repo...
Rename env-vars-template.ps1 to env-vars.ps1 and update all the parameters with your values (or sh if linux)
Now you are ready.   

## Run the terraform stack

Initialize env variables running env-vars-template.ps1 or env-vars-template.sh
Do a test awith a terrafor plan
Create teh VCN and OKE with terraform apply.