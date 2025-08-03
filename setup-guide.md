# 🚀 Complete Setup Guide: Azure + Jenkins + Pipeline

## 📋 Prerequisites Installation

### **1. Install Required Software**

#### **Node.js Installation**
```bash
# Download from: https://nodejs.org/
# Choose LTS version (v18.x or v20.x)
# Run installer and follow setup wizard

# Verify installation:
node --version
npm --version
```

#### **Git Installation**
```bash
# Download from: https://git-scm.com/
# Run installer with default settings

# Verify installation:
git --version
```

#### **Azure CLI Installation**
```bash
# Windows (using winget):
winget install Microsoft.AzureCLI

# Or download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Verify installation:
az --version
```

#### **Jenkins Installation**
```bash
# Option A: Local Installation
# Download from: https://jenkins.io/download/
# Run installer with default settings

# Option B: Docker (if you have Docker)
docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts

# Option C: Azure VM (recommended)
# Use Azure Marketplace Jenkins template
```

---

## ☁️ **STEP 2: Azure Account Setup**

### **2.1 Create Azure Account**
1. Go to [Azure Portal](https://portal.azure.com)
2. Click "Start free" or sign in with existing account
3. Complete verification process
4. Note your **Subscription ID** (you'll need this later)

### **2.2 Login to Azure CLI**
```bash
# Login to Azure
az login

# This will open browser for authentication
# Complete the login process
```

### **2.3 Create Azure Resources**
```bash
# Set your variables (replace with your values)
RESOURCE_GROUP="your-resource-group-name"
STORAGE_ACCOUNT="yourstorageaccountname"
FUNCTION_APP_NAME="your-function-app-name"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
    --name $STORAGE_ACCOUNT \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_LRS

# Create function app
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
echo "Subscription ID: $SUBSCRIPTION_ID"
```

### **2.4 Create Service Principal for Jenkins**
```bash
# Create service principal
az ad sp create-for-rbac \
    --name "jenkins-azure-deploy-$FUNCTION_APP_NAME" \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
    --output json

# Save the output - you'll need these values:
# - appId (Client ID)
# - password (Client Secret)  
# - tenant (Tenant ID)
```

---

## 🔧 **STEP 3: GitHub Repository Setup**

### **3.1 Create GitHub Repository**
1. Go to [GitHub](https://github.com)
2. Click "New repository"
3. Name: `azure-function-jenkins-pipeline`
4. Make it Public or Private
5. Don't initialize with README (we already have one)

### **3.2 Push Code to GitHub**
```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit: Azure Function with Jenkins CI/CD pipeline"

# Create main branch
git branch -M main

# Add remote repository (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/azure-function-jenkins-pipeline.git

# Push to GitHub
git push -u origin main
```

### **3.3 Create GitHub Personal Access Token**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` (full control of private repositories)
   - `admin:repo_hook` (if using webhooks)
4. Copy the token (you'll need it for Jenkins)

---

## 🏗️ **STEP 4: Jenkins Setup**

### **4.1 Install Jenkins**
```bash
# If using local installation:
# 1. Download Jenkins from https://jenkins.io/download/
# 2. Run installer
# 3. Follow setup wizard
# 4. Note the initial admin password

# If using Docker:
docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts

# If using Azure VM:
# 1. Go to Azure Portal
# 2. Create VM using Jenkins template
# 3. Connect to VM and follow setup
```

### **4.2 Access Jenkins**
1. Open browser: `http://localhost:8080` (local) or your VM IP
2. Enter initial admin password (found in Jenkins home directory)
3. Install suggested plugins
4. Create admin user

### **4.3 Install Required Jenkins Plugins**
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab
3. Search and install these plugins:
   - ✅ **GitHub Plugin**
   - ✅ **Azure CLI Plugin**
   - ✅ **Pipeline Plugin**
   - ✅ **HTML Publisher Plugin**
   - ✅ **Credentials Plugin**
   - ✅ **Git Plugin**

### **4.4 Configure Jenkins Credentials**
1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **System** → **Global credentials** → **Add Credentials**
3. Add these credentials:

#### **Azure Service Principal Credentials**
```
Kind: Secret text
ID: AZURE_CLIENT_ID
Description: Azure Client ID
Secret: [Your Service Principal App ID]
```

```
Kind: Secret text  
ID: AZURE_CLIENT_SECRET
Description: Azure Client Secret
Secret: [Your Service Principal Password]
```

```
Kind: Secret text
ID: AZURE_TENANT_ID  
Description: Azure Tenant ID
Secret: [Your Service Principal Tenant ID]
```

#### **GitHub Personal Access Token**
```
Kind: Secret text
ID: GITHUB_TOKEN
Description: GitHub Personal Access Token
Secret: [Your GitHub Personal Access Token]
```

### **4.5 Configure GitHub Integration**
1. Go to **Manage Jenkins** → **Configure System**
2. Find **GitHub** section
3. Add GitHub Server:
   - **Name**: GitHub
   - **API URL**: https://api.github.com
   - **Credentials**: Select your GitHub token
4. Click **Test connection** to verify

---

## ⚙️ **STEP 5: Update Configuration Files**

### **5.1 Update Jenkinsfile**
Edit your `Jenkinsfile` and replace the placeholder values:

```groovy
environment {
    // Replace these with your actual values
    FUNCTION_APP_NAME = 'your-function-app-name'
    RESOURCE_GROUP = 'your-resource-group-name'
    AZURE_SUBSCRIPTION_ID = 'your-subscription-id'
}
```

### **5.2 Update azure-deploy-config.json**
Edit `azure-deploy-config.json`:

```json
{
  "azure": {
    "functionAppName": "your-function-app-name",
    "resourceGroup": "your-resource-group-name", 
    "subscriptionId": "your-subscription-id",
    "location": "eastus"
  },
  "jenkins": {
    "pipelineName": "azure-function-pipeline",
    "githubRepo": "your-username/azure-function-jenkins-pipeline",
    "branch": "main"
  }
}
```

### **5.3 Push Updated Configuration**
```bash
# Commit and push your changes
git add .
git commit -m "Update configuration with Azure values"
git push
```

---

## 🚀 **STEP 6: Create Jenkins Pipeline**

### **6.1 Create New Pipeline Job**
1. Go to Jenkins dashboard
2. Click **New Item**
3. Enter name: `azure-function-pipeline`
4. Select **Pipeline**
5. Click **OK**

### **6.2 Configure Pipeline**
1. **General** section:
   - ✅ **GitHub project**: `https://github.com/YOUR_USERNAME/azure-function-jenkins-pipeline`

2. **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/YOUR_USERNAME/azure-function-jenkins-pipeline.git`
   - **Credentials**: Select your GitHub token
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`

3. **Build Triggers** (optional):
   - ✅ **GitHub hook trigger for GITScm polling** (if using webhooks)

4. Click **Save**

### **6.3 Configure GitHub Webhook (Optional)**
1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. **Payload URL**: `http://your-jenkins-url/github-webhook/`
4. **Content type**: `application/json`
5. **Events**: Just the push event
6. Click **Add webhook**

---

## 🧪 **STEP 7: Test the Pipeline**

### **7.1 Trigger Pipeline**
1. Go to your Jenkins pipeline job
2. Click **Build Now**
3. Monitor the build progress

### **7.2 Monitor Pipeline Stages**
The pipeline should execute these stages:
1. **Checkout** ✅ - Clones code from GitHub
2. **Build** ✅ - Installs dependencies and creates package
3. **Test** ✅ - Runs automated tests (7 tests)
4. **Deploy** ✅ - Deploys to Azure Functions
5. **Verification** ✅ - Tests deployed function

### **7.3 Check Build Results**
1. Click on the build number
2. Click **Console Output** to see detailed logs
3. Verify all stages completed successfully

---

## 🔍 **STEP 8: Verify Deployment**

### **8.1 Test Azure Function**
```bash
# Get function URL
FUNCTION_URL=$(az functionapp function show \
    --resource-group your-resource-group-name \
    --name your-function-app-name \
    --function-name HelloWorld \
    --query "invokeUrlTemplate" \
    --output tsv)

echo "Function URL: $FUNCTION_URL"

# Test the function
curl "$FUNCTION_URL"

# Test with name parameter
curl "$FUNCTION_URL?name=YourName"

# Test POST request
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"TestUser"}' \
    "$FUNCTION_URL"
```

### **8.2 Verify in Azure Portal**
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your Function App
3. Click on **Functions** → **HelloWorld**
4. Click **Get Function URL**
5. Test the URL in browser

---

## 📊 **STEP 9: Assignment Verification**

### **9.1 Run Verification Script**
```bash
# Run the verification script we created
node verify-assignment.js
```

### **9.2 Check Grading Criteria**
- ✅ **Jenkins Setup (3%)**: Jenkins configured with GitHub integration
- ✅ **Pipeline Stages (3%)**: Build, Test, Deploy stages working
- ✅ **Test Cases (2%)**: 7 tests implemented (exceeds requirement of 3)
- ✅ **Azure Deployment (2%)**: Function deployed and accessible

### **9.3 Prepare Submission**
1. **GitHub Repository URL**: `https://github.com/YOUR_USERNAME/azure-function-jenkins-pipeline`
2. **Jenkins Job URL**: `http://your-jenkins-url/job/azure-function-pipeline/`
3. **Azure Function URL**: `https://your-function-app-name.azurewebsites.net/api/HelloWorld`

---

## 🐛 **Troubleshooting Common Issues**

### **Azure Authentication Issues**
```bash
# Re-login to Azure
az logout
az login

# Verify subscription
az account show

# Check service principal
az ad sp list --display-name "jenkins-azure-deploy-*"
```

### **Jenkins Pipeline Failures**
1. Check **Console Output** for error messages
2. Verify credentials are correctly configured
3. Check Azure CLI is installed on Jenkins server
4. Verify function app name and resource group exist

### **GitHub Integration Issues**
1. Verify Personal Access Token has correct permissions
2. Check repository URL is correct
3. Test GitHub connection in Jenkins configuration

### **Test Failures**
```bash
# Run tests locally first
npm install
npm test

# Check Node.js version compatibility
node --version
```

---

## 🎯 **Final Checklist**

Before submitting, ensure you have:

- [ ] ✅ All software installed (Node.js, Git, Azure CLI, Jenkins)
- [ ] ✅ Azure account created and logged in
- [ ] ✅ Azure resources created (Function App, Resource Group, Storage)
- [ ] ✅ Service Principal created and credentials saved
- [ ] ✅ GitHub repository created and code pushed
- [ ] ✅ GitHub Personal Access Token created
- [ ] ✅ Jenkins installed and configured
- [ ] ✅ Required Jenkins plugins installed
- [ ] ✅ Jenkins credentials configured
- [ ] ✅ Pipeline job created and configured
- [ ] ✅ Pipeline runs successfully through all stages
- [ ] ✅ Azure Function deployed and accessible
- [ ] ✅ All tests pass
- [ ] ✅ Function responds correctly to requests

**Expected Result: 10/10 (100%) Grade**

---

## 📞 **Support Resources**

- **Azure Documentation**: https://docs.microsoft.com/en-us/azure/
- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **GitHub Documentation**: https://docs.github.com/
- **Azure Functions Documentation**: https://docs.microsoft.com/en-us/azure/azure-functions/

---

*This guide covers all requirements for Assignment 3: Jenkins CI/CD Pipeline for Azure Functions.* 