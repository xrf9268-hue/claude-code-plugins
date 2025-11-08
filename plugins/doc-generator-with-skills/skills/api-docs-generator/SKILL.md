---
name: api-docs-generator
description: Generate comprehensive API documentation from code. Use when user asks to create API docs, document endpoints, generate OpenAPI specs, or create API reference documentation.
---

# API Documentation Generator Skill

This skill helps generate comprehensive API documentation from source code.

## Capabilities

- Analyze code to identify API endpoints, functions, and classes
- Generate markdown documentation with proper formatting
- Create OpenAPI/Swagger specifications
- Document request/response formats
- Include usage examples

## When to Use This Skill

Activate this skill when the user requests:
- "Generate API documentation"
- "Document the API endpoints"
- "Create API reference docs"
- "Generate OpenAPI spec"
- "Document REST API"

## Documentation Format

Generate documentation in the following structure:

```markdown
# API Documentation

## Endpoint Name

**Method**: GET/POST/PUT/DELETE
**Path**: `/api/v1/resource`

### Description
Brief description of what this endpoint does.

### Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| param1 | string | Yes | Description |

### Request Example
\`\`\`json
{
  "field": "value"
}
\`\`\`

### Response Example
\`\`\`json
{
  "result": "success"
}
\`\`\`

### Error Codes
- 400: Bad Request
- 404: Not Found
- 500: Internal Server Error
```

## Best Practices

1. **Analyze thoroughly**: Read all relevant code files before generating documentation
2. **Be comprehensive**: Include all public APIs, endpoints, and functions
3. **Include examples**: Provide realistic request/response examples
4. **Document errors**: List all possible error codes and their meanings
5. **Keep it updated**: Suggest updating docs when code changes are detected
6. **Use standard formats**: Follow OpenAPI/Swagger specifications when applicable

## Supporting Tools

When this skill is active, you have access to:
- Code analysis tools to parse source files
- File writing tools to create documentation files
- Format validation for OpenAPI specs
