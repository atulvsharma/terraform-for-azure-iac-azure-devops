#!/bin/bash
set -e

echo "Initializing Terraform backend for all environments..."

cd terraform-manifests

for env in dev qa prod stage; do
  echo "Applying Terraform backend for $env"
  terraform init -backend-config=backend.tfvars
  terraform apply -var-file=$env.tfvars -auto-approve
done