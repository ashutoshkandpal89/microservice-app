# Azure Deployment Guide

This guide will walk you through deploying your microservice application to Azure Container Apps with full CI/CD integration.

## Prerequisites

1. **Azure CLI** - Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. **Azure Account** - With an active subscription
3. **GitHub Repository** - With admin access to add secrets

## Step 1: Install Azure CLI (macOS)

```bash
# Install using Homebrew
brew install azure-cli

# Or install using curl
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Step 2: Login to Azure

```bash
az login
```

This will open your browser for authentication.

## Step 3: Set up Azure Infrastructure

Run the Azure infrastructure setup script:

```bash
# Make sure you're in the project directory
./deploy-azure.sh
```

This script will create:
- Resource Group (`rg-microservice-app`)
- Azure Container Registry (`acrmicroserviceapp`)
- Cosmos DB with MongoDB API (`cosmos-microservice-app`)
- Container Apps Environment (`microservice-env`)
- Log Analytics Workspace and Application Insights

**Important**: Save the output values - you'll need them for GitHub secrets.

## Step 4: Create Container Apps

After the infrastructure is ready, create the container apps:

```bash
./create-container-apps.sh
```

This will create:
- Backend Container App (`backend-app`)
- Frontend Container App (`frontend-app`)

## Step 5: Set up GitHub Secrets

Go to your GitHub repository: https://github.com/ashutoshkandpal89/microservice-app/settings/secrets/actions

Add these secrets (use values from the script outputs):

### Required Secrets:
- `AZURE_REGISTRY_LOGIN_SERVER` - Your ACR login server (e.g., `acrmicroserviceapp.azurecr.io`)
- `AZURE_REGISTRY_USERNAME` - ACR username
- `AZURE_REGISTRY_PASSWORD` - ACR password
- `AZURE_MONGODB_URI` - Cosmos DB connection string
- `AZURE_RESOURCE_GROUP` - Resource group name (`rg-microservice-app`)
- `AZURE_CONTAINER_ENV_NAME` - Container environment name (`microservice-env`)
- `JWT_SECRET` - A secure random string for JWT signing
- `AZURE_CREDENTIALS` - Service principal credentials (see below)

### Creating Azure Service Principal for GitHub Actions:

```bash
# Create service principal
az ad sp create-for-rbac \
    --name "microservice-github-actions" \
    --role Contributor \
    --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-microservice-app \
    --sdk-auth

# The output should look like this (use the entire JSON as AZURE_CREDENTIALS):
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

## Step 6: Build and Push Initial Images

Before the CI/CD pipeline can deploy, you need initial images in ACR:

```bash
# Login to ACR
az acr login --name acrmicroserviceapp

# Build and push backend
cd backend
docker build -t acrmicroserviceapp.azurecr.io/backend:latest .
docker push acrmicroserviceapp.azurecr.io/backend:latest

# Build and push frontend
cd ../frontend
docker build -t acrmicroserviceapp.azurecr.io/frontend:latest .
docker push acrmicroserviceapp.azurecr.io/frontend:latest

cd ..
```

## Step 7: Test the Deployment

Push your changes to trigger the CI/CD pipeline:

```bash
git add .
git commit -m "Add Azure deployment configuration and scripts"
git push origin main
```

## Step 8: Monitor the Deployment

1. **GitHub Actions**: Check the pipeline at https://github.com/ashutoshkandpal89/microservice-app/actions
2. **Azure Portal**: Monitor resources at https://portal.azure.com

## Application URLs

After successful deployment, your application will be available at:
- **Backend**: `https://backend-app.<UNIQUE-ID>.eastus.azurecontainerapps.io`
- **Frontend**: `https://frontend-app.<UNIQUE-ID>.eastus.azurecontainerapps.io`

The actual URLs will be displayed in the deployment script outputs and GitHub Actions logs.

## Troubleshooting

### Common Issues:

1. **ACR Authentication Failed**
   ```bash
   # Re-login to ACR
   az acr login --name acrmicroserviceapp
   ```

2. **Container App Creation Failed**
   - Ensure Container Registry has the images
   - Check resource names are unique
   - Verify service principal permissions

3. **Application Not Starting**
   - Check container app logs in Azure Portal
   - Verify environment variables are set correctly
   - Check MongoDB connection string

### View Container App Logs:

```bash
# Backend logs
az containerapp logs show \
    --name backend-app \
    --resource-group rg-microservice-app \
    --follow

# Frontend logs
az containerapp logs show \
    --name frontend-app \
    --resource-group rg-microservice-app \
    --follow
```

## Scaling and Management

### Manual Scaling:
```bash
# Scale backend
az containerapp update \
    --name backend-app \
    --resource-group rg-microservice-app \
    --min-replicas 2 \
    --max-replicas 10

# Scale frontend
az containerapp update \
    --name frontend-app \
    --resource-group rg-microservice-app \
    --min-replicas 1 \
    --max-replicas 5
```

### Resource Cleanup:
```bash
# Delete entire resource group (when done)
az group delete --name rg-microservice-app --yes
```

## Cost Optimization

- Container Apps scale to zero when not in use
- Consider using Azure Free Tier resources for development
- Monitor usage in Azure Cost Management

## Security Considerations

- Rotate ACR credentials regularly
- Use Azure Key Vault for sensitive secrets in production
- Enable Azure Security Center recommendations
- Review Container App network settings for production

## Next Steps

1. Set up custom domain names
2. Configure SSL certificates
3. Implement Azure Application Insights monitoring
4. Set up Azure DevOps for additional CI/CD features
5. Configure backup strategies for Cosmos DB
