# 🚀 Formerr - Guia Completo de Deploy Multi-Cloud

## 📋 Índice
1. [Sobre o Projeto](#sobre-o-projeto)
2. [Problema e Solução](#problema-e-solução)
3. [Nova Arquitetura](#nova-arquitetura)
4. [Configuração de Secrets](#configuração-de-secrets)
5. [Como Rodar Localmente](#como-rodar-localmente)
6. [Deploy em Produção](#deploy-em-produção)
7. [Monitoramento](#monitoramento)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Sobre o Projeto

**Formerr** é uma aplicação moderna de formulários construída com:
- **Backend**: FastAPI (Python) com autenticação OAuth GitHub
- **Frontend**: Next.js (React/TypeScript) com design responsivo
- **Banco de Dados**: PostgreSQL com migrações automáticas
- **Autenticação**: OAuth 2.0 via GitHub + JWT
- **Infraestrutura**: Kubernetes na DigitalOcean com Terraform

### Funcionalidades Principais:
- ✅ Criação e gerenciamento de formulários dinâmicos
- ✅ Autenticação via GitHub (OAuth 2.0)
- ✅ Interface responsiva e moderna
- ✅ API RESTful documentada (FastAPI Swagger)
- ✅ Monitoramento com Prometheus + Grafana
- ✅ Deploy automatizado com CI/CD

---

## 🔧 Problema e Solução

### ❌ **Problema Original:**
- **Custos altos**: Bancos gerenciados em ambos os ambientes (~$50-60/mês)
- **Complexidade**: Infraestrutura espalhada e difícil de manter
- **Secrets**: Configuração confusa e inconsistente
- **Deploy**: Processos manuais e propensos a erro

### ✅ **Solução Implementada:**
- **Arquitetura Híbrida**: Staging usa PostgreSQL in-cluster (gratuito), Produção usa banco gerenciado
- **Infraestrutura como Código**: Terraform modular e reutilizável
- **CI/CD Completo**: 5 pipelines automatizados (tests + deploys)
- **Secrets Padronizados**: Mapeamento claro e documentado
- **Economia**: **$180-300/ano** em custos de infraestrutura

---

## 🏗️ Nova Arquitetura

### 🌐 **Visão Geral Multi-Cloud**

```mermaid
graph TB
    subgraph "DigitalOcean Account #1 - Production"
        K8S_PROD[Kubernetes Cluster]
        DB_PROD[Managed PostgreSQL]
        REG_PROD[Container Registry]
        LB_PROD[Load Balancer]
    end
    
    subgraph "DigitalOcean Account #2 - Staging"
        K8S_STG[Kubernetes Cluster]
        DB_STG[PostgreSQL Pod]
        REG_STG[Container Registry]
        LB_STG[Load Balancer]
    end
    
    subgraph "GitHub Actions"
        PIPELINE[CI/CD Pipelines]
    end
    
    PIPELINE --> K8S_PROD
    PIPELINE --> K8S_STG
    K8S_PROD --> DB_PROD
    K8S_STG --> DB_STG
```

### 📁 **Estrutura do Projeto**

```
Formerr/
├── 📁 backend/                    # FastAPI Application
│   ├── app/
│   │   ├── auth/                  # OAuth & JWT
│   │   ├── core/                  # Database & Models
│   │   ├── dashboard/             # API Endpoints
│   │   └── config.py              # Environment Config
│   ├── Dockerfile                 # Multi-stage build
│   └── requirements.txt
│
├── 📁 frontend/                   # Next.js Application
│   ├── src/
│   │   ├── app/                   # App Router (Next.js 13+)
│   │   ├── components/            # React Components
│   │   └── services/              # API Services
│   ├── Dockerfile                 # Optimized build
│   └── package.json
│
├── 📁 infrastructure/             # Terraform IaC
│   ├── modules/
│   │   ├── kubernetes-cluster/    # Reusable K8s module
│   │   └── container-registry/    # Reusable registry module
│   ├── digitalocean-staging/      # Staging environment
│   └── digitalocean-production/   # Production environment
│
├── 📁 charts/formerr/             # Helm Charts
│   ├── Chart.yaml                 # Dependencies (PostgreSQL, Prometheus)
│   ├── values.yaml                # Base configuration
│   ├── values-staging.yaml        # Staging overrides
│   └── values-production.yaml     # Production overrides
│
├── 📁 .github/workflows/          # CI/CD Pipelines
│   ├── backend-tests.yml          # Backend testing
│   ├── frontend-tests.yml         # Frontend testing
│   ├── integration-tests.yml      # E2E testing
│   ├── deploy-staging.yml         # Auto-deploy staging
│   └── deploy-production.yml      # Manual deploy production
│
└── 📁 k8s/                        # Additional K8s resources
    ├── monitoring/                # Prometheus + Grafana
    ├── security/                  # Network policies
    └── autoscaling/               # HPA configs
```

### 🔄 **Fluxo de Deploy**

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant DO_STG as DO Staging
    participant DO_PROD as DO Production
    
    Dev->>GH: git push main
    GH->>GH: Run Tests (Backend/Frontend/Integration)
    GH->>DO_STG: 1. Deploy Infrastructure (Terraform)
    GH->>DO_STG: 2. Build & Push Images
    GH->>DO_STG: 3. Deploy App (Helm + PostgreSQL in-cluster)
    GH->>GH: Smoke Tests
    
    Note over Dev,DO_PROD: Production Deploy (Manual)
    Dev->>GH: Create Release Tag
    GH->>DO_PROD: 1. Deploy Infrastructure (Terraform)
    GH->>DO_PROD: 2. Build & Push Images
    GH->>DO_PROD: 3. Deploy App (Helm + Managed DB)
    GH->>DO_PROD: Blue-Green Deployment
```

### 💾 **Estratégia de Banco de Dados**

| Ambiente | Tipo | Localização | Custo/Mês | Backup | SLA |
|----------|------|-------------|-----------|--------|-----|
| **Staging** | PostgreSQL Pod | In-cluster K8s | $0 | Cluster snapshots | 99.5% |
| **Production** | Managed PostgreSQL | DigitalOcean | $15-30 | Daily + PITR | 99.95% |

**Benefícios:**
- ✅ **Staging**: Desenvolvimento rápido, custo zero
- ✅ **Production**: Alta disponibilidade, menos manutenção
- ✅ **Isolamento**: Ambientes completamente separados
- ✅ **Economia**: $180-300/ano vs arquitetura anterior

---

## 🔑 Configuração de Secrets

### **GitHub Repository Secrets**

Acesse `Settings > Secrets and variables > Actions` e configure:

#### 🔐 **Tokens DigitalOcean**
```bash
DO_TOKEN_STAGING=dop_v1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DO_TOKEN_PROD=dop_v1_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

#### 🗄️ **Database - Staging (Valores Fixos)**
```bash
DATABASE_URL_STAGING=postgresql://formerr_user:staging_password_123@formerr-postgresql:5432/formerr_staging
POSTGRES_PASSWORD_STAGING=staging_password_123
```

#### 🗄️ **Database - Production (Banco Gerenciado)**
```bash
# Obter no painel DigitalOcean após criar o banco
DATABASE_URL_PROD=postgresql://doadmin:SENHA_GERADA@host:25060/formerr_production?sslmode=require
POSTGRES_PASSWORD_PROD=SENHA_GERADA_PELA_DIGITALOCEAN
```

#### 🔐 **Aplicação (OAuth & JWT)**
```bash
# GitHub OAuth App (criar em: https://github.com/settings/applications/new)
GITHUB_CLIENT_ID=seu_github_client_id_aqui
GITHUB_CLIENT_SECRET=seu_github_client_secret_aqui

# JWT & Session (gerar senhas seguras)
SECRET_KEY=sua-jwt-secret-key-muito-longa-e-segura-aqui-123456789
SESSION_SECRET=sua-session-secret-muito-longa-e-segura-aqui-987654321

# Monitoramento
GRAFANA_ADMIN_PASSWORD=senha_grafana_super_segura_123
```

### 📝 **Como Obter os Secrets**

#### 1. **Tokens DigitalOcean:**
1. Acesse [DigitalOcean API Tokens](https://cloud.digitalocean.com/account/api/tokens)
2. Clique em "Generate New Token"
3. Nome: `formerr-staging-token` / `formerr-production-token`
4. Escopo: `Write` (necessário para criar recursos)

#### 2. **GitHub OAuth App:**
1. Acesse [GitHub Developer Settings](https://github.com/settings/applications/new)
2. **Application Name**: `Formerr - Staging` / `Formerr - Production`
3. **Homepage URL**: `https://staging.formerr.dev` / `https://app.formerr.com`
4. **Authorization callback URL**: 
   - Staging: `https://api.staging.formerr.dev/auth/github/callback`
   - Production: `https://api.formerr.com/auth/github/callback`
5. Copie o `Client ID` e `Client Secret`

#### 3. **JWT & Session Secrets:**
```bash
# Gerar secrets seguros
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# ou
python -c "import secrets; print(secrets.token_urlsafe(64))"
```

---

## 💻 Como Rodar Localmente

### 🛠️ **Pré-requisitos**
```bash
# Instalar dependências
sudo apt update && sudo apt install -y docker.io docker-compose nodejs npm python3 python3-pip

# Ou no macOS
brew install docker docker-compose node python3
```

### 🚀 **Setup Rápido com Docker Compose**

1. **Clone o repositório:**
```bash
git clone https://github.com/seu-usuario/formerr.git
cd formerr
```

2. **Configure o ambiente:**
```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite as variáveis (mínimo necessário para desenvolvimento local)
nano .env
```

3. **Conteúdo do `.env` para desenvolvimento:**
```bash
# Database (Docker Compose vai criar automaticamente)
DATABASE_URL=postgresql://formerr_user:formerr_pass@postgres:5432/formerr_dev

# GitHub OAuth (criar app em: https://github.com/settings/applications/new)
GITHUB_CLIENT_ID=seu_client_id_aqui
GITHUB_CLIENT_SECRET=seu_client_secret_aqui

# JWT & Session (qualquer string para desenvolvimento)
JWT_SECRET=dev-jwt-secret-key-local
SESSION_SECRET=dev-session-secret-local

# URLs locais
FRONTEND_SUCCESS_URL=http://localhost:3000/auth/success
FRONTEND_ERROR_URL=http://localhost:3000/auth/error
OAUTH_CALLBACK_URL=http://localhost:8000/auth/github/callback
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

4. **Iniciar a aplicação:**
```bash
# Subir todos os serviços
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar os serviços
docker-compose down
```

5. **Acessar a aplicação:**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432

### 🔧 **Development Mode (Sem Docker)**

#### Backend (FastAPI):
```bash
cd backend

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Rodar servidor de desenvolvimento
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend (Next.js):
```bash
cd frontend

# Instalar dependências
npm install

# Rodar servidor de desenvolvimento
npm run dev
```

#### Database (PostgreSQL):
```bash
# Via Docker
docker run -d \
  --name formerr-postgres \
  -e POSTGRES_DB=formerr_dev \
  -e POSTGRES_USER=formerr_user \
  -e POSTGRES_PASSWORD=formerr_pass \
  -p 5432:5432 \
  postgres:15-alpine

# Criar tabelas
cd backend
python create_tables.py
```

---

## 🚀 Deploy em Produção

### 📋 **Pré-requisitos**

1. **Duas contas DigitalOcean** (ou uma com projetos separados)
2. **Domínios configurados** (ex: `formerr.com` e `staging.formerr.dev`)
3. **Secrets configurados** no GitHub repository

### 🏗️ **1. Deploy da Infraestrutura**

O Terraform criará automaticamente:
- Cluster Kubernetes
- Container Registry
- Load Balancers
- Block Storage
- VPC e Firewall

### 🎯 **2. Deploy Staging (Automático)**

```yaml
# Trigger: Push para branch main
git add .
git commit -m "feat: nova feature"
git push origin main

# Pipeline executa automaticamente:
# 1. Testes (Backend + Frontend + Integration)
# 2. Infrastructure (Terraform)
# 3. Build & Push (Docker images)
# 4. Deploy (Helm + PostgreSQL in-cluster)
# 5. Smoke Tests
```

### 🎯 **3. Deploy Production (Manual)**

```yaml
# Trigger: GitHub Release ou workflow_dispatch
# Via interface web GitHub:
Actions > Deploy to Production > Run workflow

# Ou via CLI:
gh workflow run deploy-production.yml -f version=v1.2.3

# Pipeline executa:
# 1. Infrastructure (Terraform)
# 2. Build & Push (Tagged images)
# 3. Blue-Green Deploy (Helm + Managed DB)
# 4. Health Checks
# 5. Rollback automático se falhar
```

### 🔄 **4. Configuração DNS**

```bash
# Após deploy, configurar DNS:
# Staging
staging.formerr.dev     A     IP_DO_LOAD_BALANCER_STAGING
api.staging.formerr.dev A     IP_DO_LOAD_BALANCER_STAGING

# Production
app.formerr.com         A     IP_DO_LOAD_BALANCER_PRODUCTION
api.formerr.com         A     IP_DO_LOAD_BALANCER_PRODUCTION
```

### 📊 **5. Banco de Dados Production**

```bash
# 1. Criar via DigitalOcean Console:
# - Database: PostgreSQL 15
# - Plan: Basic ($15/mês) ou Professional ($25/mês)
# - Region: Mesma do cluster K8s
# - VPC: Mesma do cluster para acesso privado

# 2. Obter credenciais e atualizar secrets:
DATABASE_URL_PROD=postgresql://doadmin:SENHA@host:25060/formerr_production?sslmode=require
POSTGRES_PASSWORD_PROD=SENHA_DO_BANCO_GERENCIADO

# 3. (Opcional) Migrar dados de staging para production:
kubectl exec -it deployment/formerr-backend -n formerr -- python create_tables.py
```

---

## 📊 Monitoramento

### 🎯 **Prometheus + Grafana (Automático)**

O monitoramento é instalado automaticamente via Helm:

```yaml
# Acesso via ingress:
https://grafana.staging.formerr.dev    # Staging
https://grafana.app.formerr.com        # Production

# Credenciais:
Username: admin
Password: {{ secrets.GRAFANA_ADMIN_PASSWORD }}
```

### 📈 **Métricas Disponíveis**

- **Aplicação**: Latência, throughput, erros HTTP
- **Kubernetes**: CPU, memória, pods, deployments
- **Database**: Conexões, queries, performance
- **Infrastructure**: Nodes, network, storage

### 🚨 **Alertas (Configurar)**

```yaml
# Exemplos de alertas importantes:
- Application down (> 2 minutos)
- High error rate (> 5%)
- Database connections high (> 80%)
- Memory usage high (> 85%)
- Disk space low (< 10%)
```

---

## 🔧 Troubleshooting

### ❌ **Problemas Comuns**

#### 1. **Deploy Falha - Secrets Incorretos**
```bash
# Verificar secrets no cluster:
kubectl get secrets -n formerr
kubectl describe secret formerr-database-secret -n formerr

# Verificar logs do pod:
kubectl logs deployment/formerr-backend -n formerr
```

#### 2. **Banco de Dados Não Conecta**
```bash
# Testar conexão local:
kubectl port-forward service/formerr-postgresql 5432:5432 -n formerr
psql -h localhost -p 5432 -U formerr_user -d formerr_staging

# Verificar configuração:
kubectl exec -it deployment/formerr-backend -n formerr -- env | grep DATABASE
```

#### 3. **OAuth GitHub Não Funciona**
```bash
# Verificar URLs de callback no GitHub App:
# Staging: https://api.staging.formerr.dev/auth/github/callback
# Production: https://api.formerr.com/auth/github/callback

# Verificar secrets:
kubectl get secret formerr-app-secrets -n formerr -o yaml
```

#### 4. **Imagens Docker Não Sobem**
```bash
# Verificar autenticação registry:
doctl registry login

# Verificar se imagem existe:
doctl registry repository list-tags formerr-staging-registry/formerr-backend

# Build manual:
cd backend
docker build -t registry.digitalocean.com/formerr-staging-registry/formerr-backend:latest .
docker push registry.digitalocean.com/formerr-staging-registry/formerr-backend:latest
```

### 🆘 **Comandos Úteis**

```bash
# Status geral do cluster:
kubectl get all -n formerr

# Logs detalhados:
kubectl logs -f deployment/formerr-backend -n formerr --tail=100

# Executar comando no pod:
kubectl exec -it deployment/formerr-backend -n formerr -- bash

# Port forward para debug:
kubectl port-forward service/formerr-backend 8000:8000 -n formerr

# Restart deployment:
kubectl rollout restart deployment/formerr-backend -n formerr

# Ver eventos do namespace:
kubectl get events -n formerr --sort-by='.lastTimestamp'

# Verificar recursos:
kubectl top pods -n formerr
kubectl describe pod <pod-name> -n formerr
```

### 🔄 **Rollback de Deploy**

```bash
# Via Helm (recomendado):
helm rollback formerr -n formerr

# Via kubectl:
kubectl rollout undo deployment/formerr-backend -n formerr
kubectl rollout undo deployment/formerr-frontend -n formerr

# Verificar status:
kubectl rollout status deployment/formerr-backend -n formerr
```

---

## 💰 Custos Estimados

### 📊 **Breakdown Mensal (USD)**

| Recurso | Staging | Production | Total |
|---------|---------|------------|-------|
| **Kubernetes Cluster** | $12 | $24 | $36 |
| **Load Balancer** | $12 | $12 | $24 |
| **Block Storage** | $1 | $5 | $6 |
| **Container Registry** | $5 | $5 | $10 |
| **Managed Database** | $0 | $15-30 | $15-30 |
| **Monitoring** | Included | Included | $0 |
| **Total/Mês** | **~$30** | **~$56-71** | **~$86-101** |

### 💡 **Otimizações de Custo**

- ✅ **PostgreSQL in-cluster** no staging (economia de $15-25/mês)
- ✅ **Shared monitoring** entre ambientes
- ✅ **Autoscaling** para otimizar recursos
- ✅ **Spot instances** para workers (adicional 20% economia)

---

## 🎉 Conclusão

Esta arquitetura oferece:

- ✅ **Deploy automatizado** com CI/CD completo
- ✅ **Infraestrutura modular** e facilmente escalável
- ✅ **Economia significativa** ($180-300/ano)
- ✅ **Monitoramento robusto** com Prometheus + Grafana
- ✅ **Segurança** com secrets bem estruturados
- ✅ **Alta disponibilidade** em produção
- ✅ **Desenvolvimento ágil** com ambiente staging dedicado

### 🚀 **Próximos Passos**

1. Configurar todos os secrets no GitHub
2. Executar o primeiro deploy de staging
3. Criar o banco de dados de produção na DigitalOcean
4. Fazer o primeiro deploy de produção
5. Configurar alertas e dashboards personalizados

---

**Documentação criada em:** Junho 2025  
**Versão:** 2.0  
**Status:** ✅ Pronto para produção
