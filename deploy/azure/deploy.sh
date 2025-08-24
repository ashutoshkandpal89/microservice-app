#!/bin/bash

# Azure Container Instances Deployment Script
# This script deploys the microservice to Azure Container Instances

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="microservice-rg"
LOCATION="East US"
REGISTRY_SERVER="ghcr.io"
REGISTRY_USERNAME="${GITHUB_ACTOR:-your-username}"
MONGODB_URI="${MONGODB_URI:-mongodb+srv://username:password@cluster.mongodb.net/microservice_db}"
JWT_SECRET="${JWT_SECRET:-your-super-secret-jwt-key-for-production}"
DOMAIN="${DOMAIN:-your-domain.com}"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed
check_azure_cli() {
    log_info "Checking Azure CLI installation..."
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first:"
        echo "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    log_success "Azure CLI is installed"
}

# Login to Azure
azure_login() {
    log_info "Checking Azure login status..."
    if ! az account show &> /dev/null; then
        log_info "Logging in to Azure..."
        az login
    else
        log_success "Already logged in to Azure"
    fi
}

# Create resource group
create_resource_group() {
    log_info "Creating resource group: $RESOURCE_GROUP"
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output table
    log_success "Resource group created"
}

# Deploy MongoDB using Azure Cosmos DB
deploy_mongodb() {
    log_info "Deploying Azure Cosmos DB for MongoDB..."
    
    COSMOS_ACCOUNT_NAME="microservice-cosmos-$(date +%s)"
    
    az cosmosdb create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$COSMOS_ACCOUNT_NAME" \
        --kind MongoDB \
        --server-version "4.2" \
        --default-consistency-level Session \
        --locations regionName="$LOCATION" failoverPriority=0 isZoneRedundant=False \
        --enable-automatic-failover false \
        --enable-multiple-write-locations false
    
    # Create database and collection
    az cosmosdb mongodb database create \
        --account-name "$COSMOS_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice_db"
    
    az cosmosdb mongodb collection create \
        --account-name "$COSMOS_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --database-name "microservice_db" \
        --name "users" \
        --shard "_id"
    
    # Get connection string
    COSMOS_CONNECTION_STRING=$(az cosmosdb keys list \
        --type connection-strings \
        --resource-group "$RESOURCE_GROUP" \
        --name "$COSMOS_ACCOUNT_NAME" \
        --query "connectionStrings[0].connectionString" \
        --output tsv)
    
    log_success "Azure Cosmos DB deployed"
    echo "Connection String: $COSMOS_CONNECTION_STRING"
}

# Deploy containers to Azure Container Instances
deploy_containers() {
    log_info "Deploying containers to Azure Container Instances..."
    
    # Deploy backend container
    log_info "Deploying backend container..."
    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-backend" \
        --image "ghcr.io/$REGISTRY_USERNAME/microservice/backend:latest" \
        --registry-server "$REGISTRY_SERVER" \
        --registry-username "$REGISTRY_USERNAME" \
        --registry-password "$GITHUB_TOKEN" \
        --cpu 1 \
        --memory 2 \
        --ports 3000 \
        --dns-name-label "microservice-api-$(date +%s)" \
        --environment-variables \
            NODE_ENV=production \
            PORT=3000 \
            CORS_ORIGIN="https://$DOMAIN" \
        --secure-environment-variables \
            MONGODB_URI="$MONGODB_URI" \
            JWT_SECRET="$JWT_SECRET" \
        --restart-policy Always
    
    # Get backend URL
    BACKEND_FQDN=$(az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-backend" \
        --query "ipAddress.fqdn" \
        --output tsv)
    
    BACKEND_URL="https://$BACKEND_FQDN"
    
    # Deploy frontend container
    log_info "Deploying frontend container..."
    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-frontend" \
        --image "ghcr.io/$REGISTRY_USERNAME/microservice/frontend:latest" \
        --registry-server "$REGISTRY_SERVER" \
        --registry-username "$REGISTRY_USERNAME" \
        --registry-password "$GITHUB_TOKEN" \
        --cpu 0.5 \
        --memory 1 \
        --ports 8080 \
        --dns-name-label "microservice-app-$(date +%s)" \
        --environment-variables \
            REACT_APP_API_URL="$BACKEND_URL" \
        --restart-policy Always
    
    # Get frontend URL
    FRONTEND_FQDN=$(az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-frontend" \
        --query "ipAddress.fqdn" \
        --output tsv)
    
    FRONTEND_URL="https://$FRONTEND_FQDN"
    
    log_success "Containers deployed successfully"
    echo "Backend URL: $BACKEND_URL"
    echo "Frontend URL: $FRONTEND_URL"
}

# Set up Application Gateway (optional)
setup_application_gateway() {
    log_info "Setting up Application Gateway..."
    
    # Create virtual network
    az network vnet create \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-vnet" \
        --address-prefix 10.0.0.0/16 \
        --subnet-name "microservice-subnet" \
        --subnet-prefix 10.0.1.0/24
    
    # Create public IP
    az network public-ip create \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-pip" \
        --allocation-method Static \
        --sku Standard
    
    # Create Application Gateway
    az network application-gateway create \
        --name "microservice-appgw" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "microservice-vnet" \
        --subnet "microservice-subnet" \
        --capacity 2 \
        --sku Standard_v2 \
        --http-settings-cookie-based-affinity Disabled \
        --frontend-port 80 \
        --http-settings-port 80 \
        --http-settings-protocol Http \
        --public-ip-address "microservice-pip"
    
    log_success "Application Gateway created"
}

# Run health checks
run_health_checks() {
    log_info "Running health checks..."
    
    # Wait for containers to be ready
    sleep 60
    
    # Check backend health
    if curl -f "http://$BACKEND_FQDN:3000/health" > /dev/null 2>&1; then
        log_success "Backend health check passed"
    else
        log_warning "Backend health check failed"
    fi
    
    # Check frontend availability
    if curl -f "http://$FRONTEND_FQDN:8080" > /dev/null 2>&1; then
        log_success "Frontend health check passed"
    else
        log_warning "Frontend health check failed"
    fi
}

# Show deployment status
show_status() {
    log_info "Deployment Status:"
    echo ""
    
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Backend Container:"
    az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-backend" \
        --query "{Name:name,State:containers[0].instanceView.currentState.state,FQDN:ipAddress.fqdn}" \
        --output table
    
    echo ""
    echo "Frontend Container:"
    az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "microservice-frontend" \
        --query "{Name:name,State:containers[0].instanceView.currentState.state,FQDN:ipAddress.fqdn}" \
        --output table
}

# Clean up resources
cleanup() {
    log_warning "This will delete all resources in resource group: $RESOURCE_GROUP"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deleting resource group..."
        az group delete --name "$RESOURCE_GROUP" --yes --no-wait
        log_success "Cleanup initiated"
    else
        log_info "Cleanup cancelled"
    fi
}

# Help function
show_help() {
    echo "Azure Container Instances Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  deploy    - Deploy the entire application"
    echo "  status    - Show deployment status"
    echo "  cleanup   - Delete all resources"
    echo "  help      - Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  MONGODB_URI   - MongoDB connection string"
    echo "  JWT_SECRET    - JWT secret key"
    echo "  GITHUB_TOKEN  - GitHub token for registry access"
    echo "  DOMAIN        - Your domain name"
    echo ""
}

# Main execution
main() {
    case "${1:-deploy}" in
        deploy)
            check_azure_cli
            azure_login
            create_resource_group
            deploy_mongodb
            deploy_containers
            run_health_checks
            show_status
            ;;
        status)
            check_azure_cli
            azure_login
            show_status
            ;;
        cleanup)
            check_azure_cli
            azure_login
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
