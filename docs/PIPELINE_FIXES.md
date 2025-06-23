# Correções de Pipeline - Resolução de Problemas

## Problemas Identificados e Soluções

### 1. ❌ Problema: Versão do Kubernetes Inválida
```
Error: invalid version slug
```

**Causa**: A versão `1.29.1-do.0` não estava mais disponível no DigitalOcean

**✅ Solução**:
- Atualizada para `1.32.5-do.0` (versão estável mais recente)
- Arquivos atualizados:
  - `infrastructure/digitalocean-production/variables.tf`
  - `infrastructure/digitalocean-staging/variables.tf`
  - `infrastructure/digitalocean-production/terraform.tfvars.example`

### 2. ❌ Problema: Recursos Duplicados
```
Error: duplicate name (firewall)
```

**Causa**: Firewalls e outros recursos já existiam no DigitalOcean com os mesmos nomes

**✅ Solução**:
- Adicionada lógica de import automático nas pipelines
- Script de verificação de conflitos: `scripts/resolve-resource-conflicts.sh`
- Usa variáveis de ambiente `TF_VAR_do_token` para evitar prompts interativos
- Modificações nos workflows:
  - `.github/workflows/deploy-production.yml`
  - `.github/workflows/deploy-staging.yml`

### 3. ❌ Problema: Backend S3 com Credenciais AWS
```
Error: AWS account ID not previously found
```

**Causa**: Backend configurado para DigitalOcean Spaces mas sem credenciais corretas

**✅ Solução**:
- Backend S3 comentado por padrão (usa backend local)
- Script de configuração: `infrastructure/digitalocean-production/setup-backend.sh`
- Documentação completa: `infrastructure/digitalocean-production/README.md`

## Alterações nas Pipelines

### Pipeline de Produção (.github/workflows/deploy-production.yml)

**Adicionado**:
```yaml
- name: Check for existing resources
  run: |
    cd infrastructure/digitalocean-production
    echo "🔍 Checking for existing resources that might conflict..."
    
    # Check for existing firewall
    FIREWALL_ID=$(doctl compute firewall list --format ID,Name --no-header | grep "formerr-production-firewall" | awk '{print $1}' || echo "")
    if [ ! -z "$FIREWALL_ID" ]; then
      echo "Found existing firewall: $FIREWALL_ID"
      terraform import digitalocean_firewall.production_firewall $FIREWALL_ID || echo "Firewall already in state"
    fi
    
    # Check for existing clusters
    CLUSTER_ID=$(doctl kubernetes cluster list --format ID,Name --no-header | grep "formerr-production" | awk '{print $1}' || echo "")
    if [ ! -z "$CLUSTER_ID" ]; then
      echo "Found existing cluster: $CLUSTER_ID"
      terraform import module.kubernetes_cluster.digitalocean_kubernetes_cluster.cluster $CLUSTER_ID || echo "Cluster already in state"
    fi
```

### Pipeline de Staging (.github/workflows/deploy-staging.yml)

**Adicionado**: Mesma lógica de verificação e import de recursos existentes

## Como Usar as Correções

### 1. Verificar Recursos Existentes (Opcional)
```bash
./scripts/resolve-resource-conflicts.sh
```

### 2. Executar Pipeline
As pipelines agora gerenciam automaticamente:
- ✅ Import de recursos existentes
- ✅ Versão correta do Kubernetes
- ✅ Backend local por padrão

### 3. Para Backend Remoto (Opcional)
```bash
cd infrastructure/digitalocean-production
./setup-backend.sh
# Descomentar backend S3 no main.tf
```

## Versões Atualizadas

| Componente | Versão Anterior | Versão Atual |
|------------|-----------------|--------------|
| Kubernetes | 1.29.1-do.0 | 1.32.5-do.0 |
| Terraform Backend | S3 (ativo) | Local (padrão) |

## Próximos Passos

1. **Testar Pipeline**: Execute a pipeline de staging primeiro
2. **Verificar Recursos**: Use o script de verificação se necessário
3. **Deploy Produção**: Pipeline de produção deve funcionar sem conflitos
4. **Backend Remoto**: Configure se necessário usando o script setup-backend.sh

## Comandos Úteis

```bash
# Verificar recursos no DigitalOcean
doctl compute firewall list
doctl kubernetes cluster list
doctl registry list

# Verificar versões disponíveis
doctl kubernetes options versions

# Status do Terraform
cd infrastructure/digitalocean-production
terraform state list
terraform plan
```

## Arquivos Modificados

```
📁 infrastructure/
├── digitalocean-production/
│   ├── variables.tf           # ✅ Versão K8s atualizada
│   ├── terraform.tfvars.example # ✅ Versão K8s atualizada
│   ├── setup-backend.sh       # 🆕 Script para backend S3
│   ├── README.md             # 🆕 Documentação completa
│   └── main.tf               # ✅ Backend S3 comentado
├── digitalocean-staging/
│   └── variables.tf          # ✅ Versão K8s atualizada
📁 .github/workflows/
├── deploy-production.yml     # ✅ Import automático
└── deploy-staging.yml        # ✅ Import automático
📁 scripts/
└── resolve-resource-conflicts.sh # 🆕 Verificação de conflitos
```

## ✅ Correção Final - Variável do_token

### Problema identificado na execução:
```
Error: No value for required variable "do_token"
Enter a value: 
```

**Causa**: O comando `terraform import` não estava recebendo a variável `do_token` necessária

**✅ Solução implementada**:
- Uso de variáveis de ambiente `TF_VAR_do_token` nas pipelines
- Terraform automaticamente reconhece variáveis que começam com `TF_VAR_`
- Evita prompts interativos durante import

**Exemplo da correção**:
```yaml
- name: Check for existing resources
  env:
    TF_VAR_do_token: ${{ secrets.DO_TOKEN_PROD }}
  run: |
    terraform import digitalocean_firewall.production_firewall $FIREWALL_ID
```

## ✅ Correção Final - Dependência Circular de Providers

### Problema identificado na execução:
```
Error: Invalid provider configuration
The configuration for provider["registry.terraform.io/hashicorp/kubernetes"] depends on values that cannot be determined until apply.
```

**Causa**: Os providers Kubernetes e Helm estavam configurados para se conectar ao cluster antes dele existir, criando uma dependência circular.

**✅ Solução implementada**:
1. **Providers condicionais**: Removida configuração estática dos providers Kubernetes/Helm
2. **Recursos Kubernetes separados**: Comentados recursos que dependem do cluster nos módulos
3. **Setup via kubectl**: Pipeline agora usa kubectl diretamente após cluster estar pronto
4. **Namespaces e secrets**: Criados via kubectl na pipeline

**Exemplo da correção**:
```yaml
- name: Setup Kubernetes Resources
  run: |
    # Save kubeconfig
    doctl kubernetes cluster kubeconfig save ${{ env.CLUSTER_NAME }}
    
    # Create namespaces
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace formerr --dry-run=client -o yaml | kubectl apply -f -
```

**Arquivos modificados**:
- `infrastructure/modules/kubernetes-cluster/main.tf` - Comentados namespaces
- `infrastructure/modules/container-registry/main.tf` - Comentados secrets
- `infrastructure/digitalocean-production/main.tf` - Removidos providers estáticos
- Pipelines atualizadas com setup via kubectl

Agora as pipelines devem funcionar corretamente, gerenciando automaticamente recursos existentes e usando versões compatíveis do Kubernetes!
