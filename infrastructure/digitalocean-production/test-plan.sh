#!/bin/bash

# Script para testar o terraform plan sem aplicar mudanças
# Este script verifica se a configuração está correta

echo "🔍 Verificando configuração do Terraform..."

# Verificar se o token está definido
if [ -z "$DO_TOKEN" ]; then
    echo "❌ Variável DO_TOKEN não está definida"
    echo "💡 Para testar: export DO_TOKEN=seu_token_aqui"
    exit 1
fi

# Navegar para o diretório correto
cd /Users/brunovieiranobre/Formerr-v1/infrastructure/digitalocean-production

# Verificar se VPC existe
echo "🔍 Verificando se a VPC 'formerr-production-vpc' existe..."
VPC_ID=$(doctl vpcs list --format ID,Name --no-header | grep "formerr-production-vpc" | awk '{print $1}' || echo "")
if [ ! -z "$VPC_ID" ]; then
    echo "✅ VPC encontrada: $VPC_ID"
else
    echo "❌ VPC 'formerr-production-vpc' não encontrada!"
    echo "💡 Você precisa criar a VPC primeiro ou verificar o nome"
    exit 1
fi

# Verificar se registry existe  
echo "🔍 Verificando se o container registry 'formerr' existe..."
if doctl registry get formerr >/dev/null 2>&1; then
    echo "✅ Registry encontrado: formerr"
else
    echo "❌ Container registry 'formerr' não encontrado!"
    echo "💡 Você pode criar com: doctl registry create formerr --subscription-tier basic"
    exit 1
fi

# Executar terraform plan
echo "🔍 Executando terraform plan..."
terraform plan \
    -var="do_token=$DO_TOKEN" \
    -var-file="terraform.tfvars"

if [ $? -eq 0 ]; then
    echo "✅ Terraform plan executado com sucesso!"
    echo "🚀 A infraestrutura está pronta para deploy"
else
    echo "❌ Terraform plan falhou"
    echo "💡 Verifique os erros acima e corrija antes de prosseguir"
    exit 1
fi
