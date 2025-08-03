pipeline {
    agent any
    
    environment {
        // Azure Function App Configuration
        FUNCTION_APP_NAME = 'cicd-fn-helloworld-canadacentral'
        RESOURCE_GROUP = 'cicd_asgmt3rg'
        AZURE_SUBSCRIPTION_ID = 'f636f191-a799-4988-a4aa-1e290b188dd1'
        
        // Azure Service Principal Credentials (set these in Jenkins credentials)
        AZURE_CLIENT_ID = credentials('AZURE_CLIENT_ID')
        AZURE_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
        AZURE_TENANT_ID = credentials('AZURE_TENANT_ID')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo 'Building the Azure Function application...'
                    
                    // Install Node.js dependencies
                    bat 'npm install'
                    
                    // Create deployment package
                    bat '''
                        echo "Creating deployment package..."
                        if exist deployment rmdir /s /q deployment
                        mkdir deployment
                        xcopy HelloWorld deployment\\HelloWorld /e /i
                        copy host.json deployment\\
                        copy package.json deployment\\
                        
                        echo "Creating local.settings.json for deployment..."
                        if exist local.settings.json (
                            copy local.settings.json deployment\\
                        ) else if exist local.settings.template.json (
                            copy local.settings.template.json deployment\\local.settings.json
                        ) else (
                            echo "Creating default local.settings.json..."
                            echo { > deployment\\local.settings.json
                            echo   "IsEncrypted": false, >> deployment\\local.settings.json
                            echo   "Values": { >> deployment\\local.settings.json
                            echo     "AzureWebJobsStorage": "UseDevelopmentStorage=true", >> deployment\\local.settings.json
                            echo     "FUNCTIONS_WORKER_RUNTIME": "node" >> deployment\\local.settings.json
                            echo   } >> deployment\\local.settings.json
                            echo } >> deployment\\local.settings.json
                        )
                        
                        echo "Build completed successfully!"
                    '''
                    
                    // Create zip file for deployment using PowerShell
                    powershell '''
                        Write-Host "Creating zip file for deployment..."
                        if (Test-Path "function.zip") { Remove-Item "function.zip" }
                        Compress-Archive -Path "deployment\\*" -DestinationPath "function.zip" -Force
                        Write-Host "Zip file created successfully!"
                    '''
                }
            }
            post {
                success {
                    echo 'Build stage completed successfully!'
                }
                failure {
                    echo 'Build stage failed!'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo 'Running automated tests...'
                    
                    // Run Jest tests
                    bat 'npm test'
                    
                    // Additional test verification
                    bat '''
                        echo "Verifying test results..."
                        if exist "coverage\\lcov-report\\index.html" (
                            echo "Test coverage report generated successfully"
                        ) else (
                            echo "Warning: Test coverage report not found"
                        )
                    '''
                }
            }
            post {
                success {
                    echo 'All tests passed successfully!'
                    // Archive test results
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'coverage/lcov-report',
                        reportFiles: 'index.html',
                        reportName: 'Test Coverage Report'
                    ])
                }
                failure {
                    echo 'Tests failed!'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying to Azure Functions...'
                    
                    // Login to Azure using Service Principal
                    bat 'echo "Logging into Azure..."'
                    bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                    
                    // Set subscription
                    bat 'echo "Setting subscription..."'
                    bat 'az account set --subscription %AZURE_SUBSCRIPTION_ID%'
                    
                    // Check if function.zip exists
                    bat 'echo "Checking if function.zip exists..."'
                    bat 'if exist function.zip (echo "function.zip found, size:" && dir function.zip) else (echo "ERROR: function.zip not found!" && exit /b 1)'
                    
                    // Debug: Check what's in the zip file
                    bat 'echo "DEBUG: Checking zip contents..."'
                    bat 'powershell "Expand-Archive -Path function.zip -DestinationPath temp-extract -Force"'
                    bat 'echo "DEBUG: Contents of deployment package:"'
                    bat 'dir temp-extract /s'
                    
                    // Deploy the function app
                    bat 'echo "Deploying function app..."'
                    bat 'az functionapp deployment source config-zip --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --src function.zip'
                    bat 'if %ERRORLEVEL% NEQ 0 (echo "ERROR: Deployment failed!" && exit /b 1)'
                    
                    // Debug: Check Function App status
                    bat 'echo "DEBUG: Checking Function App status..."'
                    bat 'az functionapp show --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --query "{name:name, state:state, kind:kind, runtime:siteConfig.linuxFxVersion}" --output table'
                    
                    // Debug: List all functions in the app
                    bat 'echo "DEBUG: Listing all functions in the app..."'
                    bat 'az functionapp function list --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --query "[].{name:name, type:type}" --output table'
                    
                    bat 'echo "Deployment completed successfully!"'
                }
            }
            post {
                success {
                    echo 'Deployment completed successfully!'
                    
                    // Get function URL for verification
                    bat '''
                        echo "Getting function URL..."
                        echo "Checking if function exists after deployment..."
                        az functionapp function show --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --function-name HelloWorld --query "name" --output tsv
                        if %ERRORLEVEL% EQU 0 (
                            echo "Function exists, getting URL..."
                            for /f "tokens=*" %%i in ('az functionapp function show --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --function-name HelloWorld --query "invokeUrlTemplate" --output tsv') do set FUNCTION_URL=%%i
                            echo "Function URL: %FUNCTION_URL%"
                            echo "You can test the function at: %FUNCTION_URL%"
                        ) else (
                            echo "Function HelloWorld not found after deployment. Checking available functions..."
                            az functionapp function list --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --query "[].name" --output table
                        )
                    '''
                }
                failure {
                    echo 'Deployment failed!'
                }
            }
        }
        
        stage('Verification') {
            steps {
                script {
                    echo 'Verifying deployment...'
                    
                    // Wait a moment for deployment to complete using PowerShell
                    powershell 'Start-Sleep -Seconds 30'
                    
                    // Test the deployed function
                    bat '''
                        echo "Testing deployed function..."
                        echo "Checking if function exists..."
                        az functionapp function show --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --function-name HelloWorld --query "name" --output tsv
                        if %ERRORLEVEL% EQU 0 (
                            echo "Function exists, getting URL..."
                            for /f "tokens=*" %%i in ('az functionapp function show --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --function-name HelloWorld --query "invokeUrlTemplate" --output tsv') do set FUNCTION_URL=%%i
                            if not "%%FUNCTION_URL%%"=="" (
                                echo "Testing function at: %%FUNCTION_URL%%"
                                curl -f "%%FUNCTION_URL%%" || echo "Function test failed"
                            ) else (
                                echo "Could not retrieve function URL"
                            )
                        ) else (
                            echo "Function HelloWorld not found. Checking available functions..."
                            az functionapp function list --resource-group %RESOURCE_GROUP% --name %FUNCTION_APP_NAME% --query "[].name" --output table
                        )
                    '''
                }
            }
            post {
                success {
                    echo 'Verification completed successfully!'
                }
                failure {
                    echo 'Verification failed!'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed!'
            
            // Clean up
            bat '''
                echo "Cleaning up build artifacts..."
                if exist function.zip del function.zip
                if exist deployment rmdir /s /q deployment
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        unstable {
            echo 'Pipeline completed with warnings!'
        }
    }
} 