#!/bin/bash

# Azure Function App Setup Script
# This script helps create the necessary Azure resources for the Jenkins CI/CD pipeline

set -e

echo "=== Azure Function App Setup Script ==="
echo "This script will create the necessary Azure resources for your Jenkins CI/CD pipeline."
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "Please log in to Azure first:"
    az login
fi

# Get user input
read -p "Enter your resource group name: " RESOURCE_GROUP
read -p "Enter your storage account name (lowercase, no special chars): " STORAGE_ACCOUNT
read -p "Enter your function app name (lowercase, no special chars): " FUNCTION_APP_NAME
read -p "Enter your location (e.g., eastus, westus2): " LOCATION

echo ""
echo "Creating Azure resources..."

# Create resource group
echo "Creating resource group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
echo "Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
    --name $STORAGE_ACCOUNT \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_LRS

# Create function app
echo "Creating function app: $FUNCTION_APP_NAME"
az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --consumption-plan-location $LOCATION \
    --runtime node \
    --runtime-version 18 \
    --functions-version 4 \
    --name $FUNCTION_APP_NAME \
    --storage-account $STORAGE_ACCOUNT \
    --os-type Linux

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

echo ""
echo "=== Azure Resources Created Successfully ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Function App: $FUNCTION_APP_NAME"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Location: $LOCATION"
echo ""

# Create service principal
echo "Creating service principal for Jenkins..."
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "jenkins-azure-deploy-$FUNCTION_APP_NAME" \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
    --output json)

# Extract values from service principal output
CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.password')
TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenant')

echo ""
echo "=== Service Principal Created ==="
echo "Client ID: $CLIENT_ID"
echo "Client Secret: $CLIENT_SECRET"
echo "Tenant ID: $TENANT_ID"
echo ""

echo "=== Next Steps ==="
echo "1. Update your Jenkinsfile with these values:"
echo "   FUNCTION_APP_NAME = '$FUNCTION_APP_NAME'"
echo "   RESOURCE_GROUP = '$RESOURCE_GROUP'"
echo "   AZURE_SUBSCRIPTION_ID = '$SUBSCRIPTION_ID'"
echo ""
echo "2. Add these credentials to Jenkins:"
echo "   AZURE_CLIENT_ID = '$CLIENT_ID'"
echo "   AZURE_CLIENT_SECRET = '$CLIENT_SECRET'"
echo "   AZURE_TENANT_ID = '$TENANT_ID'"
echo ""
echo "3. Test your function app:"
echo "   az functionapp function show --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME --function-name HelloWorld"
echo ""

echo "Setup completed successfully!" 