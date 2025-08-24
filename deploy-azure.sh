#!/bin/bash

# Azure Deployment Script for Microservice Application
# This script sets up all required Azure resources

set -e

# Configuration
RESOURCE_GROUP="rg-microservice-app"
LOCATION="eastus"
ACR_NAME="acrmicroserviceapp"
COSMOSDB_NAME="cosmos-microservice-app"
CONTAINER_ENV_NAME="microservice-env"
LOG_WORKSPACE_NAME="logs-microservice"
APP_INSIGHTS_NAME="appinsights-microservice"

echo "🚀 Starting Azure deployment for microservice application..."

# Check if user is logged in to Azure
echo "Checking Azure CLI authentication..."
az account show > /dev/null 2>&1 || {
    echo "❌ Please log in to Azure CLI first: az login"
    exit 1
}

# Create resource group
echo "📦 Creating resource group: $RESOURCE_GROUP"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output table

# Create Container Registry
echo "🐳 Creating Azure Container Registry: $ACR_NAME"
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Standard \
    --admin-enabled true \
    --location $LOCATION \
    --output table

# Create Log Analytics Workspace
echo "📊 Creating Log Analytics Workspace: $LOG_WORKSPACE_NAME"
az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_WORKSPACE_NAME \
    --location $LOCATION \
    --output table

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_WORKSPACE_NAME \
    --query customerId \
    --output tsv)

# Get workspace key
WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_WORKSPACE_NAME \
    --query primarySharedKey \
    --output tsv)

# Create Application Insights
echo "📈 Creating Application Insights: $APP_INSIGHTS_NAME"
az monitor app-insights component create \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --application-type web \
    --output table

# Create Container Apps Environment
echo "🏗️ Creating Container Apps Environment: $CONTAINER_ENV_NAME"
az containerapp env create \
    --name $CONTAINER_ENV_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --logs-workspace-id $WORKSPACE_ID \
    --logs-workspace-key $WORKSPACE_KEY \
    --output table

# Create Cosmos DB with MongoDB API
echo "🗄️ Creating Cosmos DB: $COSMOSDB_NAME"
az cosmosdb create \
    --name $COSMOSDB_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --kind MongoDB \
    --default-consistency-level Session \
    --output table

# Get Cosmos DB connection string
echo "🔐 Getting Cosmos DB connection string..."
MONGODB_URI=$(az cosmosdb keys list \
    --name $COSMOSDB_NAME \
    --resource-group $RESOURCE_GROUP \
    --type connection-strings \
    --query 'connectionStrings[0].connectionString' \
    --output tsv)

# Get ACR credentials
echo "🔐 Getting ACR credentials..."
ACR_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query 'passwords[0].value' --output tsv)

echo "✅ Azure infrastructure setup complete!"
echo ""
echo "📋 Important information for GitHub Actions secrets:"
echo "AZURE_REGISTRY_LOGIN_SERVER: $ACR_SERVER"
echo "AZURE_REGISTRY_USERNAME: $ACR_USERNAME"
echo "AZURE_REGISTRY_PASSWORD: $ACR_PASSWORD"
echo "AZURE_MONGODB_URI: $MONGODB_URI"
echo "AZURE_RESOURCE_GROUP: $RESOURCE_GROUP"
echo "AZURE_CONTAINER_ENV_NAME: $CONTAINER_ENV_NAME"
echo ""
echo "🔧 Next steps:"
echo "1. Add the above values as secrets in your GitHub repository"
echo "2. Update the CI/CD pipeline to deploy to these Azure resources"
echo "3. Push changes to trigger the deployment pipeline"
echo ""
echo "📚 GitHub repository secrets URL:"
echo "https://github.com/ashutoshkandpal89/microservice-app/settings/secrets/actions"
