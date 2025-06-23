#!/bin/bash

# Script para resolver conflitos de recursos no DigitalOcean
# Execute este script antes de rodar as pipelines se houver recursos duplicados

set -e

echo "🔧 Resolvendo conflitos de recursos no DigitalOcean..."

# Verificar se doctl está instalado e autenticado
if ! command -v doctl &> /dev/null; then
    echo "❌ doctl não está instalado. Instale: https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Verificar autenticação
if ! doctl account get &> /dev/null; then
    echo "❌ doctl não está autenticado. Execute: doctl auth init"
    exit 1
fi

echo "✅ doctl está configurado corretamente"

# Função para listar e opcionalmente remover firewalls duplicados
handle_firewalls() {
    echo "🔍 Verificando firewalls..."
    
    # Listar firewalls relacionados ao projeto
    FIREWALLS=$(doctl compute firewall list --format ID,Name --no-header | grep -E "(formerr|production|staging)" || true)
    
    if [ -z "$FIREWALLS" ]; then
        echo "✅ Nenhum firewall relacionado ao projeto encontrado"
        return
    fi
    
    echo "Firewalls encontrados:"
    echo "$FIREWALLS"
    echo ""
    
    # Verificar firewalls específicos que podem causar conflito
    PROD_FIREWALL=$(echo "$FIREWALLS" | grep "formerr-production-firewall" | awk '{print $1}' || true)
    STAGING_FIREWALL=$(echo "$FIREWALLS" | grep "formerr-staging-firewall" | awk '{print $1}' || true)
    
    if [ ! -z "$PROD_FIREWALL" ]; then
        echo "🟡 Firewall de produção encontrado: $PROD_FIREWALL"
        echo "   Este será importado automaticamente na pipeline"
    fi
    
    if [ ! -z "$STAGING_FIREWALL" ]; then
        echo "🟡 Firewall de staging encontrado: $STAGING_FIREWALL"
        echo "   Este será importado automaticamente na pipeline"
    fi
}

# Função para listar clusters
handle_clusters() {
    echo "🔍 Verificando clusters Kubernetes..."
    
    CLUSTERS=$(doctl kubernetes cluster list --format ID,Name,Status --no-header || true)
    
    if [ -z "$CLUSTERS" ]; then
        echo "✅ Nenhum cluster encontrado"
        return
    fi
    
    echo "Clusters encontrados:"
    echo "$CLUSTERS"
    echo ""
    
    # Verificar clusters específicos
    PROD_CLUSTER=$(echo "$CLUSTERS" | grep "formerr-production" | awk '{print $1}' || true)
    STAGING_CLUSTER=$(echo "$CLUSTERS" | grep "formerr-staging" | awk '{print $1}' || true)
    
    if [ ! -z "$PROD_CLUSTER" ]; then
        echo "🟡 Cluster de produção encontrado: $PROD_CLUSTER"
        echo "   Este será importado automaticamente na pipeline"
    fi
    
    if [ ! -z "$STAGING_CLUSTER" ]; then
        echo "🟡 Cluster de staging encontrado: $STAGING_CLUSTER"
        echo "   Este será importado automaticamente na pipeline"
    fi
}

# Função para verificar registries
handle_registries() {
    echo "🔍 Verificando registries..."
    
    REGISTRIES=$(doctl registry list --format Name --no-header || true)
    
    if [ -z "$REGISTRIES" ]; then
        echo "✅ Nenhum registry encontrado"
        return
    fi
    
    echo "Registries encontrados:"
    echo "$REGISTRIES"
    echo ""
}

# Função para verificar load balancers
handle_load_balancers() {
    echo "🔍 Verificando load balancers..."
    
    LBS=$(doctl compute load-balancer list --format ID,Name,Status --no-header | grep -E "(formerr|production|staging)" || true)
    
    if [ -z "$LBS" ]; then
        echo "✅ Nenhum load balancer relacionado encontrado"
        return
    fi
    
    echo "Load balancers encontrados:"
    echo "$LBS"
    echo ""
}

# Função para verificar VPCs
handle_vpcs() {
    echo "🔍 Verificando VPCs..."
    
    VPCS=$(doctl compute vpc list --format ID,Name --no-header | grep -E "(formerr|production|staging)" || true)
    
    if [ -z "$VPCS" ]; then
        echo "✅ Nenhuma VPC relacionada encontrada"
        return
    fi
    
    echo "VPCs encontradas:"
    echo "$VPCS"
    echo ""
}

# Executar verificações
echo "===================="
echo "VERIFICAÇÃO DE RECURSOS"
echo "===================="

handle_firewalls
echo ""
handle_clusters
echo ""
handle_registries
echo ""
handle_load_balancers
echo ""
handle_vpcs

echo "===================="
echo "RESUMO"
echo "===================="
echo "✅ Verificação concluída!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. As pipelines agora incluem lógica para importar recursos existentes automaticamente"
echo "2. Execute a pipeline normalmente - recursos duplicados serão gerenciados automaticamente"
echo "3. Se ainda houver problemas, verifique os logs da pipeline para mais detalhes"
echo ""
echo "🔧 COMANDOS ÚTEIS:"
echo "   - Ver firewalls: doctl compute firewall list"
echo "   - Ver clusters: doctl kubernetes cluster list"
echo "   - Ver registries: doctl registry list"
echo "   - Ver load balancers: doctl compute load-balancer list"
echo "   - Ver VPCs: doctl compute vpc list"
