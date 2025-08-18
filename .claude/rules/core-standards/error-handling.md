# Error Handling Standards

Comprehensive error handling patterns for robust applications.

## Core Principles

### Never Ignore Errors
- Always handle or propagate errors
- Log errors with full context
- Provide user-friendly messages
- Implement recovery mechanisms

## Error Handling Patterns

### Try-Catch Blocks
```typescript
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  logger.error('Operation failed', { error, context });
  throw new ApplicationError('User-friendly message', error);
}
```

### Error Boundaries (React)
```typescript
class ErrorBoundary extends React.Component {
  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.error('React error boundary', { error, info });
    // Display fallback UI
  }
}
```

### Async Error Handling
```typescript
// Express async handler wrapper
const asyncHandler = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
```

## Error Types

### Application Errors
```typescript
class ApplicationError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public originalError?: Error
  ) {
    super(message);
    this.name = 'ApplicationError';
  }
}
```

### Validation Errors
```typescript
class ValidationError extends ApplicationError {
  constructor(message: string, public fields: string[]) {
    super(message, 400);
    this.name = 'ValidationError';
  }
}
```

## Logging Standards

### Error Context
```typescript
logger.error('Database query failed', {
  query: sql,
  params: params,
  error: error.message,
  stack: error.stack,
  userId: req.user?.id,
  requestId: req.id
});
```

### Log Levels
- **ERROR**: Application errors requiring attention
- **WARN**: Recoverable issues, degraded performance
- **INFO**: Normal operations, audit trail
- **DEBUG**: Development troubleshooting

## User Communication

### Error Messages
- Be specific but not technical
- Provide actionable next steps
- Include error reference ID
- Never expose internal details

### Example Response
```json
{
  "error": {
    "message": "Unable to process your request",
    "suggestion": "Please try again or contact support",
    "reference": "ERR-2024-001234"
  }
}
```