# Load Balancer e HTTPS - Configuração

## Status Atual
O Load Balancer está **desabilitado por padrão** para evitar problemas com certificados SSL/TLS.

## Por que desabilitado?
- DigitalOcean Load Balancer com HTTPS requer certificado SSL
- Sem certificado configurado, o deploy falha
- Para ambiente de desenvolvimento/teste, HTTP é suficiente

## Como habilitar Load Balancer (apenas HTTP)

### 1. Editar terraform.tfvars
```hcl
create_load_balancer = true
enable_https = false  # Manter false
```

### 2. Aplicar mudanças
```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Como habilitar HTTPS (produção)

### Opção 1: TLS Passthrough (Recomendado)
```hcl
create_load_balancer = true
enable_https = true
```
- Deixa o Kubernetes/Ingress gerenciar os certificados
- Usa cert-manager + Let's Encrypt no cluster

### Opção 2: Certificado no Load Balancer
1. Criar certificado no DigitalOcean
2. Modificar configuração do Load Balancer:
```hcl
forwarding_rule {
  entry_protocol  = "https"
  entry_port      = 443
  target_protocol = "http"
  target_port     = 80
  certificate_id  = "seu-certificate-id"
  tls_passthrough = false
}
```

## Acesso sem Load Balancer

### kubectl port-forward
```bash
kubectl port-forward service/formerr-backend 8000:8000 -n formerr
kubectl port-forward service/formerr-frontend 3000:3000 -n formerr
```

### NodePort Service
Configure services como NodePort e acesse via IP dos nós + porta.

### Ingress Controller
Use nginx-ingress ou traefik diretamente no cluster.

## Recomendação
1. **Desenvolvimento**: Load Balancer desabilitado, use port-forward
2. **Staging**: Load Balancer HTTP apenas
3. **Produção**: Load Balancer com HTTPS + TLS passthrough + cert-manager
