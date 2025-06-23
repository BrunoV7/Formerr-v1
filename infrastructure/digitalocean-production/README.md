# Infraestrutura de Produção - DigitalOcean

Este diretório contém a configuração Terraform para o ambiente de produção no DigitalOcean.

## Pré-requisitos

1. **Terraform** instalado (versão >= 1.6)
2. **Token da API do DigitalOcean**
3. **Credenciais do DigitalOcean Spaces** (se usando backend remoto)

## Configuração

### 1. Configurar Variáveis de Ambiente

```bash
# Token da API do DigitalOcean
export DO_TOKEN="your_digitalocean_api_token"

# Se usando backend S3 (DigitalOcean Spaces)
export DIGITALOCEAN_SPACES_ACCESS_KEY="your_spaces_access_key"
export DIGITALOCEAN_SPACES_SECRET_KEY="your_spaces_secret_key"
export AWS_ACCESS_KEY_ID=$DIGITALOCEAN_SPACES_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$DIGITALOCEAN_SPACES_SECRET_KEY
export AWS_ENDPOINT_URL_S3="https://formerr-spaces.nyc3.digitaloceanspaces.com"
```

### 2. Usar o Script de Configuração (Recomendado)

```bash
# Configure suas credenciais primeiro
export DO_TOKEN="your_token"
export DIGITALOCEAN_SPACES_ACCESS_KEY="your_access_key"
export DIGITALOCEAN_SPACES_SECRET_KEY="your_secret_key"

# Execute o script de configuração
./setup-backend.sh
```

### 3. Configurar terraform.tfvars

```bash
# Copie o arquivo de exemplo
cp terraform.tfvars.example terraform.tfvars

# Edite o arquivo com suas configurações
nano terraform.tfvars
```

## Deploy

### Backend Local (Mais Simples)

Se você está usando backend local (padrão atual):

```bash
cd infrastructure/digitalocean-production
terraform init
terraform plan
terraform apply
```

### Backend Remoto (DigitalOcean Spaces)

Para usar backend remoto, descomente as linhas do backend S3 no `main.tf`:

```terraform
backend "s3" {
  bucket                      = "formerr-spaces"
  key                         = "terraform/production/terraform.tfstate"
  region                      = "us-east-1"
  endpoints = {
    s3 = "https://formerr-spaces.nyc3.digitaloceanspaces.com"
  }
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}
```

Depois execute:

```bash
./setup-backend.sh
terraform init
terraform plan
terraform apply
```

## Solução de Problemas

### Erro: "AWS account ID not previously found"

Este erro ocorre quando o Terraform tenta acessar o backend S3 sem as credenciais corretas. Soluções:

1. **Use backend local** (mais simples): As linhas do backend S3 estão comentadas por padrão
2. **Configure credenciais AWS para Spaces**: Use o script `setup-backend.sh`
3. **Verifique as variáveis de ambiente**: Certifique-se de que todas as variáveis estão definidas

### Verificar Configuração

```bash
# Verificar se as variáveis estão definidas
echo $DO_TOKEN
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

# Testar conexão com DigitalOcean
doctl auth init --access-token $DO_TOKEN
doctl account get
```

## Recursos Criados

- **VPC**: Rede privada isolada
- **Kubernetes Cluster**: Cluster gerenciado com 3 nós
- **Container Registry**: Registro privado para imagens Docker
- **Load Balancer**: Balanceador de carga com SSL
- **Firewall**: Regras de segurança

## Outputs

Após o deploy, os seguintes outputs estarão disponíveis:

- `cluster_endpoint`: Endpoint do cluster Kubernetes
- `registry_endpoint`: Endpoint do registry
- `load_balancer_ip`: IP do load balancer
