# Jenkins CI/CD Pipeline for Azure Functions - Assignment 3

This project demonstrates a complete CI/CD pipeline using Jenkins to deploy a "Hello World" Azure Function. The pipeline includes build, test, and deploy stages with comprehensive automated testing.

## Project Structure

```
├── HelloWorld/
│   ├── function.json          # Azure Function configuration
│   └── index.js              # Main function code
├── tests/
│   └── HelloWorld.test.js    # Test cases (5+ tests)
├── package.json              # Node.js dependencies
├── host.json                 # Azure Functions host configuration
├── local.settings.json       # Local development settings
├── jest.config.js           # Jest test configuration
├── Jenkinsfile              # Jenkins pipeline definition
└── README.md                # This file
```

## Features

- **Azure Function**: Simple HTTP-triggered "Hello World" function
- **Comprehensive Testing**: 5+ automated test cases using Jest
- **Jenkins Pipeline**: Complete CI/CD pipeline with Build, Test, and Deploy stages
- **Azure Integration**: Automated deployment to Azure Functions
- **Test Coverage**: Automated test coverage reporting

## Prerequisites

### 1. Azure Account Setup
- Azure subscription with access to Azure Functions
- Azure CLI installed and configured
- Service Principal created for Jenkins authentication

### 2. Jenkins Server Setup
- Jenkins server installed and running
- Required plugins installed:
  - GitHub Plugin
  - Azure CLI Plugin
  - Pipeline Plugin
  - HTML Publisher Plugin

### 3. GitHub Repository
- GitHub account with a repository for this project
- GitHub Personal Access Token for Jenkins integration

## Setup Instructions

### Step 1: Azure Function App Creation

1. **Create Function App in Azure Portal:**
   ```bash
   az group create --name your-resource-group --location eastus
   az storage account create --name yourstorageaccount --location eastus --resource-group your-resource-group --sku Standard_LRS
   az functionapp create --resource-group your-resource-group --consumption-plan-location eastus --runtime node --runtime-version 18 --functions-version 4 --name your-function-app-name --storage-account yourstorageaccount
   ```

2. **Note down the following values:**
   - Function App Name: `your-function-app-name`
   - Resource Group: `your-resource-group`
   - Subscription ID: `your-subscription-id`

### Step 2: Azure Service Principal Setup

1. **Create Service Principal:**
   ```bash
   az ad sp create-for-rbac --name "jenkins-azure-deploy" --role contributor --scopes /subscriptions/your-subscription-id/resourceGroups/your-resource-group
   ```

2. **Note the output values:**
   - `appId` (Client ID)
   - `password` (Client Secret)
   - `tenant` (Tenant ID)

### Step 3: Jenkins Configuration

1. **Install Required Plugins:**
   - Go to Jenkins > Manage Jenkins > Manage Plugins
   - Install: GitHub Plugin, Azure CLI Plugin, Pipeline Plugin, HTML Publisher Plugin

2. **Configure Azure Credentials:**
   - Go to Jenkins > Manage Jenkins > Manage Credentials
   - Add credentials for:
     - `AZURE_CLIENT_ID` (Secret text)
     - `AZURE_CLIENT_SECRET` (Secret text)
     - `AZURE_TENANT_ID` (Secret text)

3. **Configure GitHub Integration:**
   - Go to Jenkins > Manage Jenkins > Configure System
   - Add GitHub server configuration with your Personal Access Token

### Step 4: Update Jenkinsfile Configuration

Update the environment variables in `Jenkinsfile`:

```groovy
environment {
    FUNCTION_APP_NAME = 'your-function-app-name'
    RESOURCE_GROUP = 'your-resource-group'
    AZURE_SUBSCRIPTION_ID = 'your-subscription-id'
}
```

### Step 5: Create Jenkins Pipeline

1. **Create New Pipeline Job:**
   - Go to Jenkins > New Item
   - Select "Pipeline" and name it "azure-function-pipeline"

2. **Configure Pipeline:**
   - Select "Pipeline script from SCM"
   - Choose "Git" as SCM
   - Enter your GitHub repository URL
   - Set branch to `main` or `master`
   - Script path: `Jenkinsfile`

3. **Configure Webhook (Optional):**
   - In GitHub repository settings, add webhook
   - URL: `http://your-jenkins-url/github-webhook/`
   - Content type: `application/json`

## Pipeline Stages

### 1. Checkout Stage
- Clones code from GitHub repository

### 2. Build Stage
- Installs Node.js dependencies (`npm install`)
- Creates deployment package (zip file)
- Prepares artifacts for deployment

### 3. Test Stage
- Runs automated tests using Jest
- Generates test coverage reports
- Archives test results

**Test Cases Included:**
1. Basic HTTP response with "Hello, World!"
2. Personalized message with name parameter
3. Response with name in request body
4. Edge case handling (empty name)
5. Logging functionality verification
6. Project configuration validation

### 4. Deploy Stage
- Authenticates with Azure using Service Principal
- Deploys function app using Azure CLI
- Creates deployment package

### 5. Verification Stage
- Tests the deployed function
- Verifies successful deployment
- Provides function URL for testing

## Testing the Pipeline

### Manual Testing
1. **Trigger Pipeline:**
   - Go to Jenkins pipeline job
   - Click "Build Now"

2. **Monitor Execution:**
   - View console output for each stage
   - Check test results and coverage reports

3. **Verify Deployment:**
   - Check Azure Portal for deployed function
   - Test function URL in browser or Postman

### Automated Testing
The pipeline automatically runs when:
- Code is pushed to GitHub (if webhook configured)
- Manual build is triggered
- Scheduled builds (if configured)

## Test Cases Details

The project includes 5+ comprehensive test cases:

1. **Basic Functionality Test:**
   - Verifies 200 status code
   - Checks "Hello, World!" response
   - Validates response headers

2. **Parameter Handling Test:**
   - Tests custom name parameter
   - Verifies personalized response

3. **Request Body Test:**
   - Tests name parameter in request body
   - Ensures proper JSON handling

4. **Edge Case Test:**
   - Handles empty name parameter
   - Ensures graceful error handling

5. **Logging Test:**
   - Verifies logging functionality
   - Ensures proper context usage

6. **Configuration Test:**
   - Validates package.json structure
   - Checks function.json configuration

## Troubleshooting

### Common Issues

1. **Azure Authentication Failed:**
   - Verify Service Principal credentials in Jenkins
   - Check Azure CLI installation on Jenkins server

2. **Tests Failing:**
   - Ensure Node.js and npm are installed
   - Check Jest configuration

3. **Deployment Failed:**
   - Verify Function App name and Resource Group
   - Check Azure subscription access

4. **GitHub Integration Issues:**
   - Verify Personal Access Token
   - Check repository permissions

### Debugging Steps

1. **Check Jenkins Console Output:**
   - Review detailed logs for each stage
   - Look for error messages and stack traces

2. **Verify Azure Resources:**
   - Check Azure Portal for resource existence
   - Verify Function App status

3. **Test Locally:**
   - Run `npm install` and `npm test` locally
   - Verify function works with Azure Functions Core Tools

## Submission Requirements

### 1. GitHub Repository URL
Provide the link to your GitHub repository containing:
- Azure Function code
- Jenkinsfile
- Test cases
- Documentation

### 2. Jenkins Job URL/Screenshot
Provide either:
- Public Jenkins job URL, or
- Screenshot showing successful pipeline execution with all stages passed

### 3. Azure Function URL
Provide the URL of your deployed Azure Function for verification.

## Grading Criteria

- **Jenkins Setup (3%)**: Proper Jenkins configuration and GitHub integration
- **Pipeline Stages (3%)**: Build, Test, and Deploy stages functioning correctly
- **Test Cases (2%)**: At least 3 test cases executed during Test stage
- **Azure Deployment (2%)**: Successful deployment to Azure Functions

## Additional Notes

- Ensure all sensitive information (credentials, keys) is stored securely in Jenkins credentials
- Regularly update dependencies and security patches
- Monitor Azure costs and clean up unused resources
- Consider implementing additional security measures for production deployments

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Jenkins and Azure documentation
3. Consult with your instructor for assignment-specific guidance 