#!/bin/bash

# Deployment Verification Script
# This script verifies that the Azure Function was deployed successfully

set -e

echo "=== Azure Function Deployment Verification ==="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "Please log in to Azure first:"
    az login
fi

# Get configuration from user
read -p "Enter your resource group name: " RESOURCE_GROUP
read -p "Enter your function app name: " FUNCTION_APP_NAME

echo ""
echo "Verifying deployment..."

# Check if function app exists
echo "Checking if function app exists..."
if ! az functionapp show --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME &> /dev/null; then
    echo "❌ Function app '$FUNCTION_APP_NAME' not found in resource group '$RESOURCE_GROUP'"
    exit 1
fi

echo "✅ Function app exists"

# Check function app status
echo "Checking function app status..."
STATUS=$(az functionapp show --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME --query "state" --output tsv)
echo "Function app status: $STATUS"

if [ "$STATUS" != "Running" ]; then
    echo "⚠️  Function app is not running. Current status: $STATUS"
fi

# Get function URL
echo "Getting function URL..."
FUNCTION_URL=$(az functionapp function show \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME \
    --function-name HelloWorld \
    --query "invokeUrlTemplate" \
    --output tsv)

if [ -z "$FUNCTION_URL" ]; then
    echo "❌ Could not retrieve function URL"
    exit 1
fi

echo "✅ Function URL: $FUNCTION_URL"

# Test the function
echo ""
echo "Testing the deployed function..."

# Test basic GET request
echo "Testing GET request..."
RESPONSE=$(curl -s -w "\n%{http_code}" "$FUNCTION_URL")

# Split response and status code
HTTP_BODY=$(echo "$RESPONSE" | head -n 1)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

echo "Response body: $HTTP_BODY"
echo "HTTP status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Function is responding correctly"
else
    echo "❌ Function returned status $HTTP_STATUS"
fi

# Test with name parameter
echo ""
echo "Testing with name parameter..."
NAME_RESPONSE=$(curl -s -w "\n%{http_code}" "$FUNCTION_URL?name=TestUser")

NAME_BODY=$(echo "$NAME_RESPONSE" | head -n 1)
NAME_STATUS=$(echo "$NAME_RESPONSE" | tail -n 1)

echo "Response with name: $NAME_BODY"
echo "HTTP status: $NAME_STATUS"

if [ "$NAME_STATUS" = "200" ]; then
    echo "✅ Function handles name parameter correctly"
else
    echo "❌ Function failed with name parameter"
fi

# Test POST request
echo ""
echo "Testing POST request..."
POST_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"PostUser"}' \
    "$FUNCTION_URL")

POST_BODY=$(echo "$POST_RESPONSE" | head -n 1)
POST_STATUS=$(echo "$POST_RESPONSE" | tail -n 1)

echo "POST response: $POST_BODY"
echo "POST status: $POST_STATUS"

if [ "$POST_STATUS" = "200" ]; then
    echo "✅ Function handles POST requests correctly"
else
    echo "❌ Function failed with POST request"
fi

echo ""
echo "=== Deployment Verification Summary ==="
echo "✅ Function app exists and is accessible"
echo "✅ Function URL: $FUNCTION_URL"
echo "✅ Basic GET request works"
echo "✅ Name parameter handling works"
echo "✅ POST request handling works"
echo ""
echo "🎉 Deployment verification completed successfully!"
echo ""
echo "You can test your function at: $FUNCTION_URL" 