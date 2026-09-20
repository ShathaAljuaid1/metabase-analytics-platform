#!/bin/bash
set -e

echo "Getting secrets from Azure Key Vault..."

az login --identity --output none

export POSTGRES_PASSWORD=$(az keyvault secret show \
  --vault-name kv-metabase-project \
  --name PostgresPassword \
  --query value -o tsv)

export ANALYTICS_PASSWORD=$(az keyvault secret show \
  --vault-name kv-metabase-project \
  --name AnalyticsPassword \
  --query value -o tsv)

echo "Secrets loaded successfully."

docker compose up -d

echo "Metabase services started."
