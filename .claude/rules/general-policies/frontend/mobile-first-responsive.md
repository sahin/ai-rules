# Mobile-First Responsive Design Rules

## Purpose
Comprehensive mobile-first responsive design patterns to ensure optimal user experience across all device sizes, with specific focus on hydroponic farm management interfaces that must work effectively on tablets and smartphones in greenhouse environments.

## 🚨 CRITICAL: Mobile-First Requirements

### Mandatory Responsive Checklist
- ✅ **Mobile-First CSS**: All styles start from mobile and scale up
- ✅ **Touch-Friendly Design**: Minimum 44px touch targets for farm operations
- ✅ **Readable Text**: Minimum 16px font size for outdoor visibility  
- ✅ **Optimized Performance**: <3s load time on 3G connections
- ✅ **Offline Capability**: Critical farm data accessible offline
- ✅ **Accessible Navigation**: One-handed operation for greenhouse work

## Mobile-First Design Principles

### Viewport and Base Setup
```css
/* Mobile-first responsive foundation */
* {
  box-sizing: border-box;
}

html {
  font-size: 16px; /* Minimum for outdoor readability */
  line-height: 1.6;
  -webkit-text-size-adjust: 100%;
}

body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg-primary);
  color: var(--text-primary);
}

/* Viewport meta tag requirement */
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Responsive Breakpoint Strategy
```css
/* Mobile-first breakpoint system */
:root {
  --mobile: 320px;    /* Small phones */
  --mobile-lg: 480px; /* Large phones */
  --tablet: 768px;    /* Tablets */
  --desktop: 1024px;  /* Desktop */
  --desktop-lg: 1440px; /* Large desktop */
}

/* Base styles (mobile-first) */
.container {
  width: 100%;
  padding: 1rem;
  max-width: 1200px;
  margin: 0 auto;
}

/* Scale up for larger screens */
@media (min-width: 768px) {
  .container {
    padding: 1.5rem;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 2rem;
  }
}
```

## ClarosFarm-Specific Responsive Patterns

### Farm Dashboard Mobile Layout
```tsx
// Mobile-optimized farm dashboard
const FarmDashboard: React.FC = () => {
  return (
    <div className="dashboard-mobile">
      {/* Mobile-first sensor grid */}
      <div className="sensor-grid">
        <div className="sensor-card">
          <div className="sensor-value-large">25.5°C</div>
          <div className="sensor-label">Temperature</div>
          <div className="sensor-status status-normal">Normal</div>
        </div>
      </div>
      
      {/* Collapsible sections for mobile */}
      <Accordion>
        <AccordionItem title="Quick Actions">
          <div className="quick-actions-mobile">
            <TouchButton variant="primary">
              Water Plants
            </TouchButton>
            <TouchButton variant="warning">
              Check pH
            </TouchButton>
          </div>
        </AccordionItem>
      </Accordion>
    </div>
  );
};

// Mobile-first styles
const dashboardStyles = `
.dashboard-mobile {
  padding: 0.5rem;
  
  @media (min-width: 768px) {
    padding: 1rem;
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 1rem;
  }
}

.sensor-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.75rem;
  margin-bottom: 1rem;
  
  @media (min-width: 480px) {
    grid-template-columns: repeat(2, 1fr);
  }
  
  @media (min-width: 1024px) {
    grid-template-columns: repeat(4, 1fr);
  }
}

.sensor-card {
  background: var(--card-bg);
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  border: 1px solid var(--border-light);
  min-height: 120px; /* Adequate touch target */
  
  @media (min-width: 768px) {
    min-height: 140px;
  }
}

.sensor-value-large {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 0.25rem;
  
  @media (min-width: 768px) {
    font-size: 2rem;
  }
}
`;
```

### Touch-Friendly Component Patterns
```tsx
// Touch-optimized button component
interface TouchButtonProps {
  variant: 'primary' | 'secondary' | 'warning' | 'danger';
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
  fullWidth?: boolean;
}

const TouchButton: React.FC<TouchButtonProps> = ({ 
  variant, 
  children, 
  onClick, 
  disabled = false,
  fullWidth = false 
}) => {
  return (
    <button 
      className={`touch-button touch-button--${variant} ${fullWidth ? 'touch-button--full' : ''}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};

// Touch-friendly styles
const touchButtonStyles = `
.touch-button {
  min-height: 44px; /* Apple/Google recommended minimum */
  min-width: 44px;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  touch-action: manipulation; /* Prevent double-tap zoom */
  user-select: none;
  
  /* Larger touch targets on mobile */
  @media (max-width: 767px) {
    min-height: 48px;
    padding: 0.875rem 1.25rem;
  }
  
  &:active {
    transform: scale(0.98);
  }
  
  &--full {
    width: 100%;
  }
  
  &--primary {
    background: var(--primary);
    color: white;
    
    &:hover:not(:disabled) {
      background: var(--primary-dark);
    }
  }
  
  &--warning {
    background: var(--warning);
    color: var(--warning-text);
  }
}
`;
```

### Responsive Navigation for Farm Management
```tsx
// Mobile-first navigation component
const FarmNavigation: React.FC = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);
  
  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);
  
  return (
    <nav className="farm-nav">
      {isMobile ? (
        <MobileNavigation 
          isOpen={isMenuOpen}
          onToggle={setIsMenuOpen}
        />
      ) : (
        <DesktopNavigation />
      )}
    </nav>
  );
};

const MobileNavigation: React.FC<{
  isOpen: boolean;
  onToggle: (open: boolean) => void;
}> = ({ isOpen, onToggle }) => {
  return (
    <>
      {/* Mobile header */}
      <div className="mobile-header">
        <div className="farm-selector-mobile">
          <FarmSwitcher />
        </div>
        <button 
          className="menu-toggle"
          onClick={() => onToggle(!isOpen)}
          aria-label="Toggle menu"
        >
          {isOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>
      
      {/* Slide-out menu */}
      <div className={`mobile-menu ${isOpen ? 'mobile-menu--open' : ''}`}>
        <NavItem href="/dashboard" icon={<Home />}>
          Dashboard
        </NavItem>
        <NavItem href="/sensors" icon={<Thermometer />}>
          Sensors
        </NavItem>
        <NavItem href="/irrigation" icon={<Droplets />}>
          Irrigation
        </NavItem>
        <NavItem href="/alerts" icon={<AlertTriangle />}>
          Alerts
        </NavItem>
      </div>
    </>
  );
};

// Mobile navigation styles
const mobileNavStyles = `
.mobile-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1rem;
  background: var(--nav-bg);
  border-bottom: 1px solid var(--border);
}

.menu-toggle {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  color: var(--text-primary);
  min-height: 44px;
  min-width: 44px;
}

.mobile-menu {
  position: fixed;
  top: 0;
  right: -100%;
  height: 100vh;
  width: 280px;
  background: var(--nav-bg);
  transition: right 0.3s ease;
  z-index: 1000;
  padding-top: 4rem;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.1);
  
  &--open {
    right: 0;
  }
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 1rem 1.5rem;
  color: var(--text-primary);
  text-decoration: none;
  min-height: 44px;
  
  &:hover, &:focus {
    background: var(--nav-hover);
  }
  
  svg {
    margin-right: 0.75rem;
    width: 20px;
    height: 20px;
  }
}
`;
```

## Performance Optimization for Mobile

### Lazy Loading and Code Splitting
```tsx
// Mobile-optimized lazy loading
const Dashboard = lazy(() => import('../pages/Dashboard'));
const SensorDetails = lazy(() => import('../pages/SensorDetails'));
const IrrigationControl = lazy(() => import('../pages/IrrigationControl'));

// Progressive image loading
const OptimizedImage: React.FC<{
  src: string;
  alt: string;
  className?: string;
}> = ({ src, alt, className }) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [inView, setInView] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);
  
  useEffect(() => {
    if (imgRef.current && 'IntersectionObserver' in window) {
      const observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            setInView(true);
            observer.disconnect();
          }
        },
        { threshold: 0.1 }
      );
      
      observer.observe(imgRef.current);
      return () => observer.disconnect();
    }
  }, []);
  
  return (
    <div className={`image-container ${className || ''}`} ref={imgRef}>
      {inView && (
        <img
          src={src}
          alt={alt}
          onLoad={() => setIsLoaded(true)}
          className={`responsive-image ${isLoaded ? 'loaded' : ''}`}
        />
      )}
    </div>
  );
};
```

### Mobile-Specific Data Loading
```tsx
// Optimize data loading for mobile
const useMobileOptimizedData = (farmId: string) => {
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);
  
  // Load minimal data on mobile
  const { data: sensors } = useSWR(
    `/api/farms/${farmId}/sensors${isMobile ? '?minimal=true' : ''}`,
    fetcher
  );
  
  // Progressive data loading
  const { data: detailedSensors } = useSWR(
    !isMobile ? `/api/farms/${farmId}/sensors/detailed` : null,
    fetcher
  );
  
  return {
    sensors: isMobile ? sensors : detailedSensors || sensors,
    isLoading: !sensors
  };
};

// Mobile-specific API endpoints
export const createMobileOptimizedEndpoints = (router: Router) => {
  // Minimal sensor data for mobile
  router.get('/api/farms/:farmId/sensors', async (req, res) => {
    const { minimal } = req.query;
    const { farmId } = req.params;
    
    if (minimal === 'true') {
      // Return only essential data for mobile
      const sensors = await getSensorsMinimal(farmId);
      return res.json(sensors);
    }
    
    const sensors = await getSensorsDetailed(farmId);
    res.json(sensors);
  });
};
```

## Responsive Testing Patterns

### Mobile-First Test Strategy
```tsx
// Mobile-responsive component testing
describe('FarmDashboard Responsive Behavior', () => {
  beforeEach(() => {
    // Mock window.innerWidth
    Object.defineProperty(window, 'innerWidth', {
      writable: true,
      configurable: true,
      value: 375, // iPhone SE width
    });
  });
  
  test('displays mobile layout on small screens', () => {
    render(<FarmDashboard />);
    
    // Check mobile-specific elements
    expect(screen.getByTestId('mobile-menu-toggle')).toBeInTheDocument();
    expect(screen.queryByTestId('desktop-sidebar')).not.toBeInTheDocument();
  });
  
  test('sensor grid adapts to screen size', () => {
    const { rerender } = render(<FarmDashboard />);
    
    // Mobile: single column
    const sensorGrid = screen.getByTestId('sensor-grid');
    expect(sensorGrid).toHaveClass('grid-cols-1');
    
    // Tablet: two columns
    window.innerWidth = 768;
    fireEvent(window, new Event('resize'));
    rerender(<FarmDashboard />);
    
    expect(sensorGrid).toHaveClass('grid-cols-2');
  });
  
  test('touch targets meet minimum size requirements', () => {
    render(<FarmDashboard />);
    
    const buttons = screen.getAllByRole('button');
    buttons.forEach(button => {
      const styles = getComputedStyle(button);
      const height = parseInt(styles.minHeight, 10);
      const width = parseInt(styles.minWidth, 10);
      
      expect(height).toBeGreaterThanOrEqual(44);
      expect(width).toBeGreaterThanOrEqual(44);
    });
  });
});

// Visual regression tests for responsive design
test('visual regression across breakpoints', async ({ page }) => {
  await page.goto('/dashboard');
  
  const breakpoints = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1440, height: 900 }
  ];
  
  for (const breakpoint of breakpoints) {
    await page.setViewportSize({ 
      width: breakpoint.width, 
      height: breakpoint.height 
    });
    
    await page.waitForSelector('.dashboard-loaded');
    
    await expect(page).toHaveScreenshot(
      `dashboard-${breakpoint.name}.png`,
      {
        fullPage: true,
        mask: [page.locator('.real-time-data')]
      }
    );
  }
});
```

## Accessibility and Usability

### Mobile Accessibility Patterns
```tsx
// Accessible mobile form components
const MobileFriendlyForm: React.FC = () => {
  return (
    <form className="mobile-form">
      <div className="form-group">
        <label htmlFor="sensor-name" className="form-label">
          Sensor Name
        </label>
        <input
          id="sensor-name"
          type="text"
          className="form-input touch-optimized"
          aria-describedby="sensor-name-help"
        />
        <div id="sensor-name-help" className="form-help">
          Enter a descriptive name for the sensor
        </div>
      </div>
      
      <div className="form-group">
        <fieldset className="form-fieldset">
          <legend className="form-legend">Sensor Type</legend>
          <div className="radio-group">
            <label className="radio-label touch-friendly">
              <input type="radio" name="sensor-type" value="temperature" />
              <span className="radio-custom"></span>
              Temperature
            </label>
            <label className="radio-label touch-friendly">
              <input type="radio" name="sensor-type" value="humidity" />
              <span className="radio-custom"></span>
              Humidity
            </label>
          </div>
        </fieldset>
      </div>
    </form>
  );
};

// Mobile form styles
const mobileFormStyles = `
.mobile-form {
  padding: 1rem;
  max-width: 100%;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-input {
  width: 100%;
  min-height: 44px;
  padding: 0.75rem;
  font-size: 16px; /* Prevent zoom on iOS */
  border: 1px solid var(--border);
  border-radius: 8px;
  
  &:focus {
    outline: 2px solid var(--primary);
    outline-offset: 2px;
  }
}

.radio-label {
  display: flex;
  align-items: center;
  min-height: 44px;
  padding: 0.5rem;
  cursor: pointer;
  
  input[type="radio"] {
    margin-right: 0.75rem;
    transform: scale(1.2); /* Larger touch target */
  }
}
`;
```

### Dark Mode and High Contrast
```css
/* Mobile-first dark mode support */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1a1a1a;
    --text-primary: #ffffff;
    --border: #333333;
    --card-bg: #2a2a2a;
  }
}

/* High contrast mode for greenhouse visibility */
@media (prefers-contrast: high) {
  :root {
    --bg-primary: #000000;
    --text-primary: #ffffff;
    --border: #ffffff;
    --primary: #00ff00; /* High visibility green */
  }
  
  .sensor-card {
    border-width: 2px;
  }
}

/* Reduced motion preferences */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Performance Budgets and Monitoring

### Mobile Performance Budgets
```javascript
// Performance budget configuration
const performanceBudgets = {
  mobile: {
    firstContentfulPaint: 2000, // 2 seconds
    largestContentfulPaint: 2500, // 2.5 seconds
    cumulativeLayoutShift: 0.1,
    firstInputDelay: 100, // 100ms
    totalBlockingTime: 200,
    bundleSize: 250000 // 250KB
  },
  tablet: {
    firstContentfulPaint: 1500,
    largestContentfulPaint: 2000,
    cumulativeLayoutShift: 0.1,
    firstInputDelay: 100,
    totalBlockingTime: 150,
    bundleSize: 350000 // 350KB
  }
};

// Performance monitoring
export const trackMobilePerformance = () => {
  if ('web-vital' in window) {
    import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(console.log);
      getFID(console.log);
      getFCP(console.log);
      getLCP(console.log);
      getTTFB(console.log);
    });
  }
};
```

## Best Practices Summary

### DO's
- ✅ Start with mobile design and scale up
- ✅ Use minimum 44px touch targets
- ✅ Implement progressive enhancement
- ✅ Optimize for 3G network speeds
- ✅ Test on real devices in greenhouse conditions
- ✅ Use system fonts for better performance
- ✅ Implement proper focus management
- ✅ Support landscape and portrait orientations

### DON'Ts
- ❌ Don't rely on hover states for mobile
- ❌ Don't use font-size smaller than 16px
- ❌ Don't ignore touch gesture conflicts
- ❌ Don't assume fast network connections
- ❌ Don't forget offline capabilities
- ❌ Don't use tiny touch targets
- ❌ Don't ignore accessibility requirements
- ❌ Don't forget to test on actual devices

This mobile-first responsive design system ensures ClarosFarm interfaces work optimally across all devices while maintaining the specific requirements for agricultural environments and greenhouse operations.