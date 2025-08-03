const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Mock Azure Functions context
const mockContext = {
    log: jest.fn(),
    res: {}
};

// Import the function
const functionCode = fs.readFileSync(path.join(__dirname, '../HelloWorld/index.js'), 'utf8');
const functionModule = new Function('module', 'exports', functionCode + '\nreturn module.exports;');
const helloWorldFunction = functionModule({}, {});

describe('HelloWorld Azure Function Tests', () => {
    beforeEach(() => {
        mockContext.res = {};
        jest.clearAllMocks();
    });

    // Test Case 1: Basic HTTP response with "Hello, World!"
    test('should return 200 status code and Hello World message', async () => {
        const req = {
            query: {},
            body: {}
        };

        await helloWorldFunction(mockContext, req);

        expect(mockContext.res.status).toBe(200);
        expect(mockContext.res.body).toBe('Hello, World! This HTTP triggered function executed successfully.');
        expect(mockContext.res.headers['Content-Type']).toBe('text/plain');
        expect(mockContext.res.headers['X-Function-Name']).toBe('HelloWorld');
    });

    // Test Case 2: Response with custom name parameter
    test('should return personalized message when name is provided', async () => {
        const req = {
            query: { name: 'John' },
            body: {}
        };

        await helloWorldFunction(mockContext, req);

        expect(mockContext.res.status).toBe(200);
        expect(mockContext.res.body).toBe('Hello, John. This HTTP triggered function executed successfully.');
    });

    // Test Case 3: Response with name in request body
    test('should return personalized message when name is in request body', async () => {
        const req = {
            query: {},
            body: { name: 'Jane' }
        };

        await helloWorldFunction(mockContext, req);

        expect(mockContext.res.status).toBe(200);
        expect(mockContext.res.body).toBe('Hello, Jane. This HTTP triggered function executed successfully.');
    });

    // Test Case 4: Edge case - empty name parameter
    test('should handle empty name parameter gracefully', async () => {
        const req = {
            query: { name: '' },
            body: {}
        };

        await helloWorldFunction(mockContext, req);

        expect(mockContext.res.status).toBe(200);
        expect(mockContext.res.body).toBe('Hello, . This HTTP triggered function executed successfully.');
    });

    // Test Case 5: Verify logging functionality
    test('should log request processing', async () => {
        const req = {
            query: {},
            body: {}
        };

        await helloWorldFunction(mockContext, req);

        expect(mockContext.log).toHaveBeenCalledWith('JavaScript HTTP trigger function processed a request.');
    });
});

// Additional integration test for package.json
describe('Project Configuration Tests', () => {
    test('package.json should exist and have required dependencies', () => {
        const packageJson = JSON.parse(fs.readFileSync(path.join(__dirname, '../package.json'), 'utf8'));
        
        expect(packageJson.name).toBe('azure-function-hello-world');
        expect(packageJson.scripts.test).toBe('jest');
        expect(packageJson.dependencies).toHaveProperty('@azure/functions');
        expect(packageJson.devDependencies).toHaveProperty('jest');
    });

    test('function.json should exist and have correct configuration', () => {
        const functionJson = JSON.parse(fs.readFileSync(path.join(__dirname, '../HelloWorld/function.json'), 'utf8'));
        
        expect(functionJson.bindings).toHaveLength(2);
        expect(functionJson.bindings[0].type).toBe('httpTrigger');
        expect(functionJson.bindings[0].authLevel).toBe('anonymous');
        expect(functionJson.bindings[1].type).toBe('http');
    });
}); 