#!/bin/bash

# Local Testing Script for Azure Function
# This script helps test the function locally before deploying to Azure

set -e

echo "=== Local Testing Script for Azure Function ==="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install it first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install it first."
    exit 1
fi

echo "Installing dependencies..."
npm install

echo ""
echo "Running tests..."
npm test

echo ""
echo "=== Test Results ==="
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed!"
    exit 1
fi

echo ""
echo "=== Function Code Review ==="
echo "Function location: HelloWorld/index.js"
echo "Function configuration: HelloWorld/function.json"
echo ""

# Display function code
echo "Function code:"
echo "=============="
cat HelloWorld/index.js
echo ""

echo "Function configuration:"
echo "======================"
cat HelloWorld/function.json
echo ""

echo "=== Local Testing Completed ==="
echo "The function is ready for deployment to Azure!"
echo ""
echo "Next steps:"
echo "1. Push your code to GitHub"
echo "2. Configure Jenkins pipeline"
echo "3. Deploy to Azure Functions" 