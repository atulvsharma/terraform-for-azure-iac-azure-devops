#!/bin/bash
set -e

#echo "AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
#echo "AZURE_TENANT_ID=$AZURE_TENANT_ID"
#echo "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"

echo "🔐 Logging in to Azure using service principal..."
az login --service-principal \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID" >/dev/null

az account set --subscription "$AZURE_SUBSCRIPTION_ID"

echo "📦 Creating resource group if it doesn't exist..."
az group create \
  --name "$BACKEND_RG" \
  --location "$LOCATION" \
  --output none

echo "📡 Checking if storage account exists in your resource group..."
if az storage account show --name "$BACKEND_STORAGE" --resource-group "$BACKEND_RG" >/dev/null 2>&1; then
  echo "✅ Storage account '$BACKEND_STORAGE' exists in resource group '$BACKEND_RG'."
else
  echo "❌ Storage account '$BACKEND_STORAGE' doesn't exist. Attempting to create it..."

  # Ensure name is globally unique by appending a short random suffix if not already unique
  UNIQUE_NAME="${BACKEND_STORAGE}$(openssl rand -hex 2)"
  echo "🔄 Storage account name '$BACKEND_STORAGE' is unavailable. Trying '$UNIQUE_NAME'..."
  BACKEND_STORAGE="$UNIQUE_NAME"

  az storage account create \
    --name "$BACKEND_STORAGE" \
    --resource-group "$BACKEND_RG" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --output none

  echo "✅ Storage account '$BACKEND_STORAGE' created."
fi

echo "🔑 Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$BACKEND_RG" \
  --account-name "$BACKEND_STORAGE" \
  --query "[0].value" -o tsv)

echo "📁 Creating blob container if it doesn't exist..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$BACKEND_STORAGE" \
  --account-key "$ACCOUNT_KEY" \
  --output none

echo "✅ Backend storage is ready."

# Export updated name for downstream steps
echo "BACKEND_STORAGE=$BACKEND_STORAGE" >> $GITHUB_ENV



#echo "Creating service principal..."
#SP_JSON=$(az ad sp create-for-rbac --name terraform-sp --role contributor --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID)
#SP_APP_ID=$(echo $SP_JSON | jq -r '.appId')
#SP_PASSWORD=$(echo $SP_JSON | jq -r '.password')

#echo "Assigning Storage Account Key Operator Service Role..."
#STORAGE_ID=$(az storage account show --name $BACKEND_STORAGE --resource-group $BACKEND_RG --query "id" -o tsv)
#az role assignment create --assignee $SP_APP_ID --role "Storage Account Key Operator Service Role" --scope $STORAGE_ID

#echo "::set-output name=client_id::$SP_APP_ID"
#echo "::set-output name=client_secret::$SP_PASSWORD"
