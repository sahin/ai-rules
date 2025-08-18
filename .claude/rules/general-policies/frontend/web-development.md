# Best Practices Web Development

This document outlines universal best practices specifically for web application development, focusing on frontend concerns like routing, navigation, and UI/UX.

## 🚀 Feature Development Requirements (Web-Specific)

When implementing ANY new web feature, you MUST include:

### 1. Loading States
   - Show loading spinners/skeletons during data fetching
   - Disable buttons during mutations to prevent double-clicks
   - Use framework's loading state patterns
   - Example: `{isLoading ? <Spinner /> : <Content />}`

### 2. Comprehensive Error Handling
   - Catch and display user-friendly error messages
   - Use toast notifications for operation feedback
   - Implement error boundaries for components
   - Handle network failures gracefully
   - Example: Always include error callbacks with user notifications

### 3. Form Validation
   - Validate inputs before submission
   - Show field-level error messages
   - Prevent submission with invalid data
   - Use proper type safety for form data

### 4. Accessibility (a11y)
   - Include proper ARIA labels
   - Ensure keyboard navigation works
   - Use semantic HTML elements
   - Test with screen readers in mind

## 🛣️ Routing & Navigation Requirements

### 1. Route Testing
   - Test that all routes render without 404 errors
   - Verify deep links work correctly
   - Test navigation between routes

### 2. 404 Error Handling
   - Always include a 404 page component
   - Test that unknown routes show 404 page
   - Ensure 404 page has link back to home
   - Log 404 errors for monitoring

### 3. Route Guards
   - Implement authentication checks where needed
   - Handle unauthorized access gracefully
   - Redirect to appropriate pages

### 4. URL Structure
   - Use consistent URL patterns
   - Support both client-side and server-side routing
   - Handle trailing slashes consistently

## 🎯 UI/UX Requirements

### 1. Consistent Feedback
   - Success: Positive visual feedback
   - Error: Clear error messages
   - Loading: Visual loading indicators
   - Empty states: Helpful messaging

### 2. Form Handling
   - Disable submit during processing
   - Show validation errors inline
   - Provide clear field labels
   - Support keyboard navigation

### 3. Accessibility Standards
   - Use proper heading hierarchy
   - Include alt text for images
   - Ensure sufficient color contrast
   - Support keyboard navigation

## 🧩 Components and Hooks Structure

- One component per file unless trivially small.
- Extract data fetching and complex state into hooks (`useX.ts`).
- Keep components presentational where possible; avoid coupling to backend details.

## 🚫 DOM Element Wait Patterns (MANDATORY)

### **NEVER Use Timeouts for DOM Operations**
Arbitrary timeouts are unreliable and create race conditions. They fail when:
- System is under load
- Network is slow  
- Browser is busy
- Different devices have varying performance

❌ **BAD - Timeout-based approach:**
```javascript
// NEVER do this - arbitrary delays are unreliable
setTimeout(() => {
  renderAllWidgets();
}, 200);

// Also avoid - still using arbitrary timing
setTimeout(() => {
  document.querySelector('.my-element').click();
}, 100);
```

✅ **GOOD - Event-driven approach:**
```javascript
// Wait for specific DOM events
document.addEventListener('DOMContentLoaded', () => {
  renderAllWidgets();
});

// Use MutationObserver for dynamic content
const observer = new MutationObserver((mutations) => {
  if (document.querySelector('.target-element')) {
    renderAllWidgets();
    observer.disconnect();
  }
});
observer.observe(document.body, { childList: true, subtree: true });

// React: Use lifecycle methods or hooks
useEffect(() => {
  // Component is mounted and DOM is ready
  renderAllWidgets();
}, []);

// Custom events for complex flows
window.addEventListener('widgetsReady', () => {
  renderAllWidgets();
});

// Promise-based waiting for specific conditions
async function waitForElement(selector) {
  return new Promise(resolve => {
    if (document.querySelector(selector)) {
      return resolve(document.querySelector(selector));
    }
    
    const observer = new MutationObserver(() => {
      if (document.querySelector(selector)) {
        observer.disconnect();
        resolve(document.querySelector(selector));
      }
    });
    
    observer.observe(document.body, { childList: true, subtree: true });
  });
}

// Usage
const element = await waitForElement('.my-widget');
renderAllWidgets();
```

### **Acceptable Event-Driven Patterns:**
- `DOMContentLoaded` - Initial page load
- `load` - All resources loaded
- `MutationObserver` - Dynamic DOM changes
- Framework lifecycle hooks (React useEffect, Vue mounted, etc.)
- Custom events for application state
- Promise-based conditional waiting
- Intersection Observer for visibility
- ResizeObserver for dimension changes

### **Exception Cases:**
The ONLY acceptable timeout uses are:
- Animation sequences where timing is intentional
- Debouncing/throttling user input
- Polling external services with exponential backoff

## 🎨 Beautiful Smart Empty Data States

### 1. Empty State Design Principles
   - **Visual Appeal**: Use illustrations or icons
   - **Helpful Messaging**: Provide clear, actionable guidance
   - **Call-to-Action**: Include buttons to help users get started
   - **Context-Aware**: Different messages based on context

### 2. Smart Empty State Patterns
   - Different states for search vs filters vs no data
   - Provide relevant actions based on context
   - Use appropriate icons and colors
   - Include helpful suggestions

### 3. Empty State Guidelines
   - Use muted colors for backgrounds
   - Generous padding for breathing room
   - Subtle animations for engagement
   - Responsive design for all devices

## 🔗 API URL Management in Frontend

### **CRITICAL: No Hardcoded URLs**

**❌ NEVER DO THIS:**
```typescript
// Hardcoded URLs scattered in components
const response = await fetch('/api/users/123');
queryClient.invalidateQueries({ queryKey: ['/api/users'] });
await apiRequest('PUT', `/api/dashboard-views/${id}`, data);
```

**✅ ALWAYS DO THIS:**
```typescript
// Centralized endpoint constants
const response = await fetch(API_ENDPOINTS.users.byId(123));
queryClient.invalidateQueries({ queryKey: [API_ENDPOINTS.users.list] });
await apiRequest('PUT', DASHBOARD_ENDPOINTS.byId(id), data);
```

### **Mandatory Endpoint Structure**

Create a centralized endpoints file:
```typescript
// src/api/endpoints.ts
export const USER_ENDPOINTS = {
  list: '/api/users',
  byId: (id: string) => `/api/users/${id}` as const,
  search: (query: string) => `/api/users/search?q=${encodeURIComponent(query)}` as const,
} as const;

export const DASHBOARD_ENDPOINTS = {
  list: '/api/dashboards',
  byId: (id: string) => `/api/dashboards/${id}` as const,
  widgets: (dashboardId: string) => `/api/dashboards/${dashboardId}/widgets` as const,
} as const;
```

### **Query Key Management**
```typescript
// Align query keys with endpoints
export const userQueryKeys = {
  all: ['users'] as const,
  list: () => [...userQueryKeys.all, 'list'] as const,
  detail: (id: string) => [...userQueryKeys.all, 'detail', id] as const,
};

// Usage in React Query
useQuery({
  queryKey: userQueryKeys.detail(userId),
  queryFn: () => fetch(USER_ENDPOINTS.byId(userId)),
});
```

### **Benefits**
- **Single source of truth** for all API URLs
- **Type safety** with TypeScript
- **Easy refactoring** when API changes
- **Consistent patterns** across codebase
- **No scattered URL strings** in components

## 🚫 No Mock Data Rule

### Always Use Real Data
- **NEVER hardcode mock data in UI components**
- **No sample/demo data in production code**
- **API-first approach** - All data from backends
- **Development data belongs in seeders**

### Implementation Guidelines
- Remove all hardcoded data
- Use proper data fetching
- Show loading states while fetching
- Mock data in tests only

## 📊 Performance Guidelines (Web/UI Specific)

### 1. Optimize Queries
   - Use proper caching strategies
   - Implement pagination for large datasets
   - Optimize data transformations

### 2. Component Optimization
   - Use memoization for expensive operations
   - Implement proper dependency arrays
   - Avoid unnecessary re-renders

### 3. Bundle Optimization
   - Use code splitting
   - Implement lazy loading
   - Optimize assets

## 🔒 Security Practices (Frontend Specific)

### 1. Input Validation
   - Validate all user inputs
   - Sanitize data before processing
   - Use type safety
   - Prevent injection attacks

### 2. API Security
   - Implement authentication
   - Use HTTPS in production
   - Validate request payloads
   - Configure CORS properly

### 3. Frontend Security
   - Never store sensitive data in browser storage
   - Use secure authentication methods
   - Implement Content Security Policy
   - Escape user-generated content 