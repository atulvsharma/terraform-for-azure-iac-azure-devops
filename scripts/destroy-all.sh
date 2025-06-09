#!/bin/bash
set -e

echo "Logging into Azure..."
az login --service-principal \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID" >/dev/null

az account set --subscription "$AZURE_SUBSCRIPTION_ID"

echo "🔨 Destroying Terraform-managed infrastructure..."
terraform -chdir=terraform init \
  -backend-config="resource_group_name=${BACKEND_RG}" \
  -backend-config="storage_account_name=${BACKEND_STORAGE}" \
  -backend-config="container_name=${CONTAINER_NAME}" \
  -backend-config="key=${TF_ENV}.tfstate"

terraform -chdir=terraform destroy \
  -var-file="${TF_ENV}.tfvars" \
  -auto-approve

echo "🗑️ Deleting blob container..."
az storage container delete \
  --name "$CONTAINER_NAME" \
  --account-name "$BACKEND_STORAGE" \
  --auth-mode login \
  --output none || true

echo "💥 Deleting storage account..."
az storage account delete \
  --name "$BACKEND_STORAGE" \
  --resource-group "$BACKEND_RG" \
  --yes --output none || true

echo "🏁 Deleting resource group..."
az group delete \
  --name "$BACKEND_RG" \
  --yes \
  --no-wait \
  --output none || true

echo "✅ Cleanup complete."
