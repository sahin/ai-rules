# Frontend Development Guide

Use this guide when building UI components, implementing responsive design, or working on frontend architecture.

## Component Patterns

### Component Structure
```tsx
// Single responsibility: one component, one job
// Props interface defined inline or imported
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
  variant?: 'compact' | 'full';
}

export function UserCard({ user, onSelect, variant = 'full' }: UserCardProps) {
  // 1. Hooks at the top
  const { data, isLoading } = useUserDetails(user.id);

  // 2. Early returns for loading/error/empty
  if (isLoading) return <UserCardSkeleton />;
  if (!data) return <EmptyState message="User not found" />;

  // 3. Event handlers
  const handleClick = () => onSelect(user.id);

  // 4. Render
  return (
    <div onClick={handleClick}>
      {variant === 'full' ? <FullLayout data={data} /> : <CompactLayout data={data} />}
    </div>
  );
}
```

### State Management Rules
- Local state: `useState` for component-only state
- Shared state: lift to nearest common ancestor or use context
- Server state: React Query / TanStack Query (never store API data in global state)
- URL state: search params for filterable/shareable state
- Form state: controlled components or form libraries (react-hook-form)

### Custom Hooks
```tsx
// Extract data fetching and complex logic into hooks
function useUserDetails(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.users.get(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Extract complex state logic
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle] as const;
}
```

## Required UI States

Every async operation MUST handle all states:

### Loading States
```tsx
// Skeleton loading (preferred over spinners)
function UserListSkeleton() {
  return (
    <div role="status" aria-label="Loading users">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="animate-pulse h-16 bg-gray-200 rounded mb-2" />
      ))}
    </div>
  );
}
```

### Error States
```tsx
function ErrorState({ error, onRetry }: { error: Error; onRetry: () => void }) {
  return (
    <div role="alert">
      <p>Something went wrong loading your data.</p>
      <p className="text-sm text-gray-500">{error.message}</p>
      <button onClick={onRetry}>Try again</button>
    </div>
  );
}
```

### Empty States
```tsx
function EmptyState({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div>
      <p>{title}</p>
      {action && <div>{action}</div>}
    </div>
  );
}

// Usage: <EmptyState title="No orders yet" action={<Link to="/shop">Browse products</Link>} />
```

## Responsive Design

### Breakpoints (Mobile-First)
```css
/* Base: mobile (< 640px) */
.container { padding: 1rem; }

/* sm: >= 640px (landscape phones, small tablets) */
@media (min-width: 640px) { .container { padding: 1.5rem; } }

/* md: >= 768px (tablets) */
@media (min-width: 768px) { .container { padding: 2rem; } }

/* lg: >= 1024px (laptops) */
@media (min-width: 1024px) { .container { max-width: 1024px; } }

/* xl: >= 1280px (desktops) */
@media (min-width: 1280px) { .container { max-width: 1280px; } }
```

### Touch-Friendly Design
- Minimum touch target: 44x44px (WCAG 2.5.5)
- Spacing between interactive elements: >= 8px
- No hover-only interactions (must work on touch)
- Use `@media (hover: hover)` for hover enhancements

### Responsive Patterns
- **Stack to grid**: single column on mobile, multi-column on desktop
- **Off-canvas navigation**: hamburger menu on mobile, sidebar on desktop
- **Progressive disclosure**: show summary on mobile, full details on desktop
- **Responsive images**: `srcset` and `sizes` attributes, WebP with fallback

## Form Validation

```tsx
// Use react-hook-form + zod for type-safe validation
const schema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2).max(100),
});

type FormData = z.infer<typeof schema>;

function SignupForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await api.auth.signup(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <input {...register('email')} type="email" aria-invalid={!!errors.email} />
      {errors.email && <span role="alert">{errors.email.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating account...' : 'Sign up'}
      </button>
    </form>
  );
}
```

## Accessibility Checklist (WCAG 2.1 AA)

### Structure
- [ ] Semantic HTML (`header`, `nav`, `main`, `section`, `article`, `footer`)
- [ ] Heading hierarchy (h1 > h2 > h3, no skipped levels)
- [ ] Landmarks for screen reader navigation
- [ ] Language attribute on `<html>`

### Interactive Elements
- [ ] All interactive elements keyboard accessible
- [ ] Visible focus indicators (never `outline: none` without replacement)
- [ ] Skip-to-content link as first focusable element
- [ ] Focus trapped in modals, returned on close
- [ ] `aria-label` or `aria-labelledby` for icon-only buttons

### Content
- [ ] Color contrast >= 4.5:1 (normal text), >= 3:1 (large text)
- [ ] Information not conveyed by color alone
- [ ] All images have `alt` text (empty `alt=""` for decorative)
- [ ] Form inputs have associated `<label>` elements
- [ ] Error messages linked to inputs via `aria-describedby`

### Dynamic Content
- [ ] Live regions (`aria-live`) for dynamic updates
- [ ] Loading states announced to screen readers
- [ ] Page title updates on route changes
- [ ] Animations respect `prefers-reduced-motion`

## Performance Budgets

### Core Web Vitals Targets
| Metric | Target | Measurement |
|--------|--------|-------------|
| LCP (Largest Contentful Paint) | < 2.5s | Loading performance |
| INP (Interaction to Next Paint) | < 200ms | Interactivity |
| CLS (Cumulative Layout Shift) | < 0.1 | Visual stability |

### Bundle Size Budgets
- Initial JS bundle: < 200KB gzipped
- Per-route chunk: < 50KB gzipped
- CSS: < 50KB gzipped
- Images: use next-gen formats (WebP, AVIF), lazy load below fold

### Optimization Techniques
```tsx
// Lazy load routes
const Dashboard = lazy(() => import('./pages/Dashboard'));

// Lazy load heavy components
const Chart = lazy(() => import('./components/Chart'));

// Memoize expensive computations
const sortedItems = useMemo(() =>
  items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Debounce search input
const debouncedSearch = useDebouncedCallback(
  (value: string) => setSearchTerm(value),
  300
);

// Virtual scrolling for large lists
import { useVirtualizer } from '@tanstack/react-virtual';
```

### Image Optimization
- Use `<img loading="lazy">` for below-fold images
- Provide `width` and `height` to prevent layout shift
- Use responsive images with `srcset`
- Prefer SVG for icons and illustrations
- Compress: JPEG quality 80%, WebP quality 75%

## API URL Management

```typescript
// Centralized endpoint constants - never hardcode URLs
const API_BASE = import.meta.env.VITE_API_URL;

export const endpoints = {
  users: {
    list: () => `${API_BASE}/api/v1/users`,
    get: (id: string) => `${API_BASE}/api/v1/users/${id}`,
    create: () => `${API_BASE}/api/v1/users`,
  },
  orders: {
    list: (userId: string) => `${API_BASE}/api/v1/users/${userId}/orders`,
    get: (id: string) => `${API_BASE}/api/v1/orders/${id}`,
  },
} as const;
```

## DOM Event Patterns

```typescript
// NEVER use setTimeout for DOM operations
// Use proper observers and lifecycle hooks

// Intersection Observer for lazy loading / infinite scroll
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) loadMore();
    });
  },
  { threshold: 0.1 }
);

// Resize Observer for responsive behavior
const resizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    updateLayout(entry.contentRect);
  }
});

// Always clean up in useEffect
useEffect(() => {
  const observer = new IntersectionObserver(callback);
  observer.observe(ref.current);
  return () => observer.disconnect();
}, []);
```
