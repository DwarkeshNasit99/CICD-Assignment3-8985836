# Quick Setup Script for Assignment 3
# This script helps set up Azure resources and configuration

Write-Host "🚀 Assignment 3 Quick Setup Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az --version 2>$null
    if ($azVersion) {
        Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
    } else {
        Write-Host "❌ Azure CLI not found. Please install it first:" -ForegroundColor Red
        Write-Host "   winget install Microsoft.AzureCLI" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Azure CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   winget install Microsoft.AzureCLI" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in to Azure
try {
    $account = az account show 2>$null
    if ($account) {
        Write-Host "✅ Already logged in to Azure" -ForegroundColor Green
    } else {
        Write-Host "🔐 Please log in to Azure..." -ForegroundColor Yellow
        az login
    }
} catch {
    Write-Host "🔐 Please log in to Azure..." -ForegroundColor Yellow
    az login
}

Write-Host ""
Write-Host "📝 Please provide the following information:" -ForegroundColor Cyan

# Get user input
$resourceGroup = Read-Host "Enter Resource Group name (e.g., my-function-rg)"
$storageAccount = Read-Host "Enter Storage Account name (lowercase, no special chars, e.g., mystorageaccount)"
$functionAppName = Read-Host "Enter Function App name (lowercase, no special chars, e.g., my-function-app)"
$location = Read-Host "Enter location (e.g., eastus, westus2)"

Write-Host ""
Write-Host "🔧 Creating Azure resources..." -ForegroundColor Yellow

# Create resource group
Write-Host "Creating resource group: $resourceGroup" -ForegroundColor Cyan
az group create --name $resourceGroup --location $location

# Create storage account
Write-Host "Creating storage account: $storageAccount" -ForegroundColor Cyan
az storage account create --name $storageAccount --location $location --resource-group $resourceGroup --sku Standard_LRS

# Create function app
Write-Host "Creating function app: $functionAppName" -ForegroundColor Cyan
az functionapp create --resource-group $resourceGroup --consumption-plan-location $location --runtime node --runtime-version 20 --functions-version 4 --name $functionAppName --storage-account $storageAccount --os-type Linux

# Get subscription ID
$subscriptionId = az account show --query id --output tsv

Write-Host ""
Write-Host "✅ Azure resources created successfully!" -ForegroundColor Green
Write-Host "Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "Storage Account: $storageAccount" -ForegroundColor White
Write-Host "Function App: $functionAppName" -ForegroundColor White
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor White
Write-Host "Location: $location" -ForegroundColor White

Write-Host ""
Write-Host "🔐 Creating service principal for Jenkins..." -ForegroundColor Yellow

# Create service principal
$spOutput = az ad sp create-for-rbac --name "jenkins-azure-deploy-$functionAppName" --role contributor --scopes "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup" --output json

# Parse the output to extract values
$spData = $spOutput | ConvertFrom-Json

Write-Host ""
Write-Host "✅ Service Principal created successfully!" -ForegroundColor Green
Write-Host "Client ID: $($spData.appId)" -ForegroundColor White
Write-Host "Client Secret: $($spData.password)" -ForegroundColor White
Write-Host "Tenant ID: $($spData.tenant)" -ForegroundColor White

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Update your Jenkinsfile with these values:" -ForegroundColor White
Write-Host "   FUNCTION_APP_NAME = '$functionAppName'" -ForegroundColor Yellow
Write-Host "   RESOURCE_GROUP = '$resourceGroup'" -ForegroundColor Yellow
Write-Host "   AZURE_SUBSCRIPTION_ID = '$subscriptionId'" -ForegroundColor Yellow

Write-Host ""
Write-Host "2. Add these credentials to Jenkins:" -ForegroundColor White
Write-Host "   AZURE_CLIENT_ID = '$($spData.appId)'" -ForegroundColor Yellow
Write-Host "   AZURE_CLIENT_SECRET = '$($spData.password)'" -ForegroundColor Yellow
Write-Host "   AZURE_TENANT_ID = '$($spData.tenant)'" -ForegroundColor Yellow

Write-Host ""
Write-Host "3. Test your function app:" -ForegroundColor White
Write-Host "   az functionapp function show --resource-group $resourceGroup --name $functionAppName --function-name HelloWorld" -ForegroundColor Yellow

Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "Continue with the setup guide for Jenkins and GitHub configuration." -ForegroundColor Cyan 