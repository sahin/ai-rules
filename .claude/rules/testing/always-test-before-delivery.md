# Always Test Before Delivery Rule

## MANDATORY: Test Every Change Before Reporting Success

### The Problem This Solves
- Prevents delivering broken pages (404 errors, runtime errors)
- Saves user time from debugging AI-created issues
- Ensures quality and working code on first delivery

### Required Testing Steps

#### 1. For New Pages/Routes:
```bash
# MUST run these checks:
curl -s -o /dev/null -w "%{http_code}" <page_url>  # Should return 200
curl -s <page_url> | grep -q "error" && echo "ERRORS FOUND" || echo "No errors"
```

#### 2. For Component Changes:
- Check component prop requirements BEFORE using them
- Provide mock data that matches component interfaces
- Use error boundaries around all components

#### 3. Testing Checklist:
- [ ] Page loads without 404
- [ ] No console errors in browser
- [ ] All components render with data
- [ ] Interactive features work
- [ ] Error states handled gracefully

### Component Testing Principles:
- Always check component prop requirements before using
- Provide complete mock data matching interfaces
- Use TypeScript to catch prop mismatches
- Wrap components in error boundaries

### Localhost Testing (MANDATORY):
```bash
# Start development server
npm run dev

# Wait for server to be ready
sleep 5

# Test specific route (replace with actual route)
curl -I http://localhost:3000/your-route  # Should return HTTP 200

# Check for JavaScript errors in response
curl -s http://localhost:3000/your-route | grep -i "error\|exception\|undefined"

# Full verification sequence
npm run type-check && \
npm run lint && \
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/your-route
```

### Visual Verification Checklist:
- [ ] Page looks correct (not just loads)
- [ ] Data displays properly formatted
- [ ] Layout isn't broken or misaligned
- [ ] Interactive elements are clickable
- [ ] No placeholder/dummy data showing
- [ ] Responsive design works (if applicable)

### Error Recovery Protocol:
If errors are found after delivery:
1. Immediately acknowledge the issue
2. Fix the actual root cause, not symptoms
3. Test the fix thoroughly
4. Explain what went wrong and how it's prevented

### Quality Gates:
Before saying "it's working":
1. ✅ HTTP 200 status confirmed
2. ✅ No TypeScript errors
3. ✅ No runtime errors in console
4. ✅ Components render with real data
5. ✅ User interactions work

## This rule is MANDATORY and overrides speed of delivery