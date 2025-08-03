#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Assignment 3 Verification Script');
console.log('=====================================\n');

// Test 1: Check if all required files exist
console.log('1. Checking Required Files:');
const requiredFiles = [
    'HelloWorld/index.js',
    'HelloWorld/function.json',
    'tests/HelloWorld.test.js',
    'package.json',
    'Jenkinsfile',
    'README.md',
    'jest.config.js',
    'host.json',
    'local.settings.json'
];

let allFilesExist = true;
requiredFiles.forEach(file => {
    const exists = fs.existsSync(file);
    console.log(`   ${exists ? '✅' : '❌'} ${file}`);
    if (!exists) allFilesExist = false;
});

console.log(`\n   ${allFilesExist ? '✅ All required files present' : '❌ Some files missing'}\n`);

// Test 2: Verify package.json structure
console.log('2. Checking package.json:');
try {
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    const checks = [
        packageJson.name === 'azure-function-hello-world',
        packageJson.scripts && packageJson.scripts.test === 'jest',
        packageJson.dependencies && packageJson.dependencies['@azure/functions'],
        packageJson.devDependencies && packageJson.devDependencies.jest
    ];
    
    console.log(`   ✅ Name: ${packageJson.name}`);
    console.log(`   ✅ Test script: ${packageJson.scripts?.test}`);
    console.log(`   ✅ Azure Functions dependency: ${!!packageJson.dependencies?.['@azure/functions']}`);
    console.log(`   ✅ Jest dependency: ${!!packageJson.devDependencies?.jest}`);
    console.log(`   ${checks.every(c => c) ? '✅ Package.json structure correct' : '❌ Package.json issues found'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading package.json: ${error.message}\n`);
}

// Test 3: Verify Azure Function code
console.log('3. Checking Azure Function:');
try {
    const functionCode = fs.readFileSync('HelloWorld/index.js', 'utf8');
    const checks = [
        functionCode.includes('module.exports'),
        functionCode.includes('context.res'),
        functionCode.includes('Hello, World'),
        functionCode.includes('status: 200')
    ];
    
    console.log(`   ✅ Exports function: ${checks[0]}`);
    console.log(`   ✅ Sets response: ${checks[1]}`);
    console.log(`   ✅ Contains Hello World: ${checks[2]}`);
    console.log(`   ✅ Returns 200 status: ${checks[3]}`);
    console.log(`   ${checks.every(c => c) ? '✅ Function code correct' : '❌ Function code issues'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading function code: ${error.message}\n`);
}

// Test 4: Verify function.json configuration
console.log('4. Checking Function Configuration:');
try {
    const functionConfig = JSON.parse(fs.readFileSync('HelloWorld/function.json', 'utf8'));
    const checks = [
        functionConfig.bindings && functionConfig.bindings.length >= 2,
        functionConfig.bindings?.[0]?.type === 'httpTrigger',
        functionConfig.bindings?.[0]?.authLevel === 'anonymous',
        functionConfig.bindings?.[1]?.type === 'http'
    ];
    
    console.log(`   ✅ Has bindings: ${checks[0]}`);
    console.log(`   ✅ HTTP trigger: ${checks[1]}`);
    console.log(`   ✅ Anonymous auth: ${checks[2]}`);
    console.log(`   ✅ HTTP output: ${checks[3]}`);
    console.log(`   ${checks.every(c => c) ? '✅ Function config correct' : '❌ Function config issues'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading function.json: ${error.message}\n`);
}

// Test 5: Verify test cases
console.log('5. Checking Test Cases:');
try {
    const testCode = fs.readFileSync('tests/HelloWorld.test.js', 'utf8');
    const testCount = (testCode.match(/test\(/g) || []).length;
    const describeCount = (testCode.match(/describe\(/g) || []).length;
    
    console.log(`   ✅ Test functions found: ${testCount}`);
    console.log(`   ✅ Test suites found: ${describeCount}`);
    console.log(`   ${testCount >= 3 ? '✅ Meets requirement (3+ tests)' : '❌ Insufficient tests'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading test file: ${error.message}\n`);
}

// Test 6: Verify Jenkinsfile
console.log('6. Checking Jenkins Pipeline:');
try {
    const jenkinsfile = fs.readFileSync('Jenkinsfile', 'utf8');
    const checks = [
        jenkinsfile.includes('pipeline'),
        jenkinsfile.includes('stage'),
        jenkinsfile.includes('Build'),
        jenkinsfile.includes('Test'),
        jenkinsfile.includes('Deploy'),
        jenkinsfile.includes('npm install'),
        jenkinsfile.includes('npm test'),
        jenkinsfile.includes('az functionapp')
    ];
    
    console.log(`   ✅ Pipeline structure: ${checks[0]}`);
    console.log(`   ✅ Has stages: ${checks[1]}`);
    console.log(`   ✅ Build stage: ${checks[2]}`);
    console.log(`   ✅ Test stage: ${checks[3]}`);
    console.log(`   ✅ Deploy stage: ${checks[4]}`);
    console.log(`   ✅ NPM install: ${checks[5]}`);
    console.log(`   ✅ NPM test: ${checks[6]}`);
    console.log(`   ✅ Azure deployment: ${checks[7]}`);
    console.log(`   ${checks.every(c => c) ? '✅ Jenkinsfile complete' : '❌ Jenkinsfile issues'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading Jenkinsfile: ${error.message}\n`);
}

// Test 7: Verify Jest configuration
console.log('7. Checking Jest Configuration:');
try {
    const jestConfigContent = fs.readFileSync('jest.config.js', 'utf8');
    const checks = [
        jestConfigContent.includes('testEnvironment: \'node\''),
        jestConfigContent.includes('collectCoverage: true'),
        jestConfigContent.includes('coverageDirectory: \'coverage\''),
        jestConfigContent.includes('module.exports')
    ];
    
    console.log(`   ✅ Node environment: ${checks[0]}`);
    console.log(`   ✅ Coverage enabled: ${checks[1]}`);
    console.log(`   ✅ Coverage directory: ${checks[2]}`);
    console.log(`   ✅ Module exports: ${checks[3]}`);
    console.log(`   ${checks.every(c => c) ? '✅ Jest config correct' : '❌ Jest config issues'}\n`);
} catch (error) {
    console.log(`   ❌ Error reading jest.config.js: ${error.message}\n`);
}

console.log('=====================================');
console.log('🎯 Assignment Verification Complete!');
console.log('\nNext Steps:');
console.log('1. Push code to GitHub repository');
console.log('2. Set up Azure Function App');
console.log('3. Configure Jenkins pipeline');
console.log('4. Run full CI/CD pipeline');
console.log('\nFor detailed setup instructions, see README.md'); 