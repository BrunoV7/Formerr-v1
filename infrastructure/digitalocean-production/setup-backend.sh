#!/bin/bash

# Script para configurar credenciais do DigitalOcean Spaces como backend S3 para Terraform
# Execute este script antes de rodar terraform init

echo "Configurando credenciais para DigitalOcean Spaces..."

# Verifique se as variáveis estão definidas
if [ -z "$DIGITALOCEAN_SPACES_ACCESS_KEY" ]; then
    echo "⚠️  DIGITALOCEAN_SPACES_ACCESS_KEY não está definida"
    echo "Execute: export DIGITALOCEAN_SPACES_ACCESS_KEY=your_spaces_access_key"
fi

if [ -z "$DIGITALOCEAN_SPACES_SECRET_KEY" ]; then
    echo "⚠️  DIGITALOCEAN_SPACES_SECRET_KEY não está definida"
    echo "Execute: export DIGITALOCEAN_SPACES_SECRET_KEY=your_spaces_secret_key"
fi

if [ -z "$DO_TOKEN" ]; then
    echo "⚠️  DO_TOKEN não está definida"
    echo "Execute: export DO_TOKEN=your_digitalocean_token"
fi

# Configure as credenciais AWS para usar com DigitalOcean Spaces
export AWS_ACCESS_KEY_ID=$DIGITALOCEAN_SPACES_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$DIGITALOCEAN_SPACES_SECRET_KEY
export AWS_ENDPOINT_URL_S3="https://formerr-spaces.nyc3.digitaloceanspaces.com"
export AWS_REGION="us-east-1"

# Configure Terraform para usar DigitalOcean
export TF_VAR_do_token=$DO_TOKEN

echo "✅ Credenciais configuradas!"
echo "Agora você pode executar:"
echo "  terraform init"
echo "  terraform plan"
echo "  terraform apply"
