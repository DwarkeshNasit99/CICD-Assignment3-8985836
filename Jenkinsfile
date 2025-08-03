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
                    sh 'npm install'
                    
                    // Create deployment package
                    sh '''
                        echo "Creating deployment package..."
                        if [ -d "deployment" ]; then
                            rm -rf deployment
                        fi
                        mkdir -p deployment
                        cp -r HelloWorld deployment/
                        cp host.json deployment/
                        cp package.json deployment/
                        cp local.settings.json deployment/
                        
                        # Create zip file for deployment
                        cd deployment
                        zip -r ../function.zip .
                        cd ..
                        
                        echo "Build completed successfully!"
                    '''
                }
            }
            post {
                success {
                    echo 'Build stage completed successfully!'
                }
                failure {
                    echo 'Build stage failed!'
                    currentBuild.result = 'FAILURE'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo 'Running automated tests...'
                    
                    // Run Jest tests
                    sh 'npm test'
                    
                    // Additional test verification
                    sh '''
                        echo "Verifying test results..."
                        if [ -f "coverage/lcov-report/index.html" ]; then
                            echo "Test coverage report generated successfully"
                        else
                            echo "Warning: Test coverage report not found"
                        fi
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
                    currentBuild.result = 'FAILURE'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying to Azure Functions...'
                    
                    // Login to Azure using Service Principal
                    sh '''
                        echo "Logging into Azure..."
                        az login --service-principal \
                            -u $AZURE_CLIENT_ID \
                            -p $AZURE_CLIENT_SECRET \
                            --tenant $AZURE_TENANT_ID
                        
                        echo "Setting subscription..."
                        az account set --subscription $AZURE_SUBSCRIPTION_ID
                        
                        echo "Deploying function app..."
                        az functionapp deployment source config-zip \
                            --resource-group $RESOURCE_GROUP \
                            --name $FUNCTION_APP_NAME \
                            --src function.zip
                        
                        echo "Deployment completed successfully!"
                    '''
                }
            }
            post {
                success {
                    echo 'Deployment completed successfully!'
                    
                    // Get function URL for verification
                    sh '''
                        echo "Getting function URL..."
                        FUNCTION_URL=$(az functionapp function show \
                            --resource-group $RESOURCE_GROUP \
                            --name $FUNCTION_APP_NAME \
                            --function-name HelloWorld \
                            --query "invokeUrlTemplate" \
                            --output tsv)
                        
                        echo "Function URL: $FUNCTION_URL"
                        echo "You can test the function at: $FUNCTION_URL"
                    '''
                }
                failure {
                    echo 'Deployment failed!'
                    currentBuild.result = 'FAILURE'
                }
            }
        }
        
        stage('Verification') {
            steps {
                script {
                    echo 'Verifying deployment...'
                    
                    // Wait a moment for deployment to complete
                    sh 'sleep 30'
                    
                    // Test the deployed function
                    sh '''
                        echo "Testing deployed function..."
                        FUNCTION_URL=$(az functionapp function show \
                            --resource-group $RESOURCE_GROUP \
                            --name $FUNCTION_APP_NAME \
                            --function-name HelloWorld \
                            --query "invokeUrlTemplate" \
                            --output tsv)
                        
                        if [ ! -z "$FUNCTION_URL" ]; then
                            echo "Testing function at: $FUNCTION_URL"
                            curl -f "$FUNCTION_URL" || echo "Function test failed"
                        else
                            echo "Could not retrieve function URL"
                        fi
                    '''
                }
            }
            post {
                success {
                    echo 'Verification completed successfully!'
                }
                failure {
                    echo 'Verification failed!'
                    currentBuild.result = 'UNSTABLE'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed!'
            
            // Clean up
            sh '''
                echo "Cleaning up build artifacts..."
                rm -f function.zip
                rm -rf deployment
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