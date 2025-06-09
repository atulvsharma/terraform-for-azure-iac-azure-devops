# Terraform on Azure with Azure IaC DevOps for Terraform Project
Gernerate the ssh keys under folder ssh-keys using command -
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C "azureuser@myserver" \
    -f terraform-azure.pem  

chmod 400 terraform-azure.pem

# Terraform Providers lock for multiple platforms. Run the above command from path# /c/Users/atulv/OneDrive/Desktop/My_Documents/DevOps_Roadmap/Projects/devops_project/terraform-for-azure-iac-azure-devops/terraform-manifests

terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64

# Run the below command inorder to generate the resources specific a region e.g. dev region 
terraform apply -var-file="dev.tfvars"

