az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID
terraform -chdir=terraform init -input=false
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply -auto-approve tfplan
