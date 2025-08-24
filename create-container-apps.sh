#!/bin/bash

# Azure Container Apps Creation Script
# Run this after deploy-azure.sh to create the container apps

set -e

# Configuration (must match deploy-azure.sh)
RESOURCE_GROUP="rg-microservice-app"
LOCATION="eastus"
ACR_NAME="acrmicroserviceapp"
COSMOSDB_NAME="cosmos-microservice-app"
CONTAINER_ENV_NAME="microservice-env"

echo "🏗️ Creating Azure Container Apps..."

# Check if user is logged in to Azure
echo "Checking Azure CLI authentication..."
az account show > /dev/null 2>&1 || {
    echo "❌ Please log in to Azure CLI first: az login"
    exit 1
}

# Get ACR login server
ACR_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)

# Get MongoDB connection string
MONGODB_URI=$(az cosmosdb keys list \
    --name $COSMOSDB_NAME \
    --resource-group $RESOURCE_GROUP \
    --type connection-strings \
    --query 'connectionStrings[0].connectionString' \
    --output tsv)

echo "🔐 Retrieved Azure resources configuration"

# Create Backend Container App
echo "🚀 Creating backend container app..."
az containerapp create \
    --name backend-app \
    --resource-group $RESOURCE_GROUP \
    --environment $CONTAINER_ENV_NAME \
    --image $ACR_SERVER/backend:latest \
    --target-port 3000 \
    --ingress external \
    --cpu 0.5 \
    --memory 1Gi \
    --min-replicas 1 \
    --max-replicas 3 \
    --registry-server $ACR_SERVER \
    --env-vars \
        NODE_ENV=production \
        PORT=3000 \
        MONGODB_URI="$MONGODB_URI" \
        JWT_SECRET="your-production-jwt-secret-here" \
        CORS_ORIGIN="https://frontend-app.kindground-12345678.eastus.azurecontainerapps.io" \
        RATE_LIMIT_WINDOW_MS=900000 \
        RATE_LIMIT_MAX_REQUESTS=100 \
    --output table

# Get backend app URL
BACKEND_URL=$(az containerapp show \
    --name backend-app \
    --resource-group $RESOURCE_GROUP \
    --query 'properties.configuration.ingress.fqdn' \
    --output tsv)

echo "✅ Backend app created at: https://$BACKEND_URL"

# Create Frontend Container App
echo "🚀 Creating frontend container app..."
az containerapp create \
    --name frontend-app \
    --resource-group $RESOURCE_GROUP \
    --environment $CONTAINER_ENV_NAME \
    --image $ACR_SERVER/frontend:latest \
    --target-port 8080 \
    --ingress external \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 1 \
    --max-replicas 2 \
    --registry-server $ACR_SERVER \
    --env-vars \
        REACT_APP_API_URL="https://$BACKEND_URL" \
    --output table

# Get frontend app URL
FRONTEND_URL=$(az containerapp show \
    --name frontend-app \
    --resource-group $RESOURCE_GROUP \
    --query 'properties.configuration.ingress.fqdn' \
    --output tsv)

echo "✅ Frontend app created at: https://$FRONTEND_URL"

# Update backend CORS origin with actual frontend URL
echo "🔄 Updating backend CORS configuration..."
az containerapp update \
    --name backend-app \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars \
        CORS_ORIGIN="https://$FRONTEND_URL" \
    --output table

echo "🎉 Container Apps deployment complete!"
echo ""
echo "📋 Application URLs:"
echo "🌐 Backend:  https://$BACKEND_URL"
echo "🌐 Frontend: https://$FRONTEND_URL"
echo ""
echo "🔐 GitHub Secrets to add:"
echo "AZURE_RESOURCE_GROUP: $RESOURCE_GROUP"
echo "AZURE_CONTAINER_ENV_NAME: $CONTAINER_ENV_NAME"
echo "AZURE_MONGODB_URI: [Already provided by deploy-azure.sh]"
echo "JWT_SECRET: your-production-jwt-secret-here"
echo ""
echo "⚠️  Remember to:"
echo "1. Push Docker images to ACR before running the CI/CD pipeline"
echo "2. Add all required secrets to GitHub repository"
echo "3. Update the CI/CD workflow with actual URLs if different"
