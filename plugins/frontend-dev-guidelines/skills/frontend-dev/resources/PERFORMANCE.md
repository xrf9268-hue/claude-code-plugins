# Performance Optimization

This resource covers frontend performance optimization techniques for React applications, including code splitting, memoization, bundle optimization, and Web Vitals.

## Table of Contents

1. [Core Web Vitals](#core-web-vitals)
2. [Code Splitting](#code-splitting)
3. [Memoization Strategies](#memoization-strategies)
4. [Virtual Scrolling](#virtual-scrolling)
5. [Bundle Optimization](#bundle-optimization)
6. [Image Optimization](#image-optimization)
7. [Performance Monitoring](#performance-monitoring)

---

## Core Web Vitals

Google's Core Web Vitals are the key metrics to optimize for.

### 1. Largest Contentful Paint (LCP)

**Target**: < 2.5 seconds

**Measures**: Loading performance (when the largest content element becomes visible)

**Optimization strategies:**

```typescript
// ✅ Lazy load images
<img
  src="hero.jpg"
  loading="lazy"
  alt="Hero image"
/>

// ✅ Preload critical resources
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />

// ✅ Use next/image for automatic optimization (Next.js)
import Image from 'next/image';

<Image
  src="/hero.jpg"
  width={1200}
  height={600}
  priority // Preload critical images
  alt="Hero"
/>
```

### 2. First Input Delay (FID) / Interaction to Next Paint (INP)

**Target**: < 100ms (FID), < 200ms (INP)

**Measures**: Responsiveness (time from user interaction to response)

**Optimization strategies:**

```typescript
// ✅ Use code splitting to reduce main thread work
const HeavyComponent = lazy(() => import('./HeavyComponent'));

// ✅ Defer non-critical JavaScript
useEffect(() => {
  // Load analytics after page is interactive
  setTimeout(() => {
    import('./analytics').then(({ init }) => init());
  }, 2000);
}, []);

// ✅ Use web workers for heavy computations
const worker = new Worker(new URL('./worker.ts', import.meta.url));
worker.postMessage({ data: largeDataset });
worker.onmessage = (e) => setProcessedData(e.data);
```

### 3. Cumulative Layout Shift (CLS)

**Target**: < 0.1

**Measures**: Visual stability (unexpected layout shifts)

**Optimization strategies:**

```typescript
// ✅ Always specify dimensions for images
<img src="photo.jpg" width="400" height="300" alt="Photo" />

// ✅ Reserve space for dynamic content
<div style={{ minHeight: '200px' }}>
  {loading ? <Skeleton /> : <Content />}
</div>

// ❌ Avoid: Images without dimensions
<img src="photo.jpg" alt="Photo" /> // Layout shift when loaded!

// ❌ Avoid: Inserting content above viewport
<div>
  {showBanner && <Banner />} // Pushes content down
  <MainContent />
</div>
```

---

## Code Splitting

### 1. Route-Based Splitting

Split code by routes for optimal loading:

```typescript
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy load route components
const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Profile = lazy(() => import('./pages/Profile'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

### 2. Component-Based Splitting

Split heavy components:

```typescript
import { lazy, Suspense } from 'react';

// Heavy chart library - load on demand
const HeavyChart = lazy(() => import('./components/HeavyChart'));
const VideoPlayer = lazy(() => import('./components/VideoPlayer'));

function Dashboard() {
  const [showChart, setShowChart] = useState(false);

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Load Chart</button>

      {showChart && (
        <Suspense fallback={<ChartSkeleton />}>
          <HeavyChart data={chartData} />
        </Suspense>
      )}
    </div>
  );
}
```

### 3. Library Splitting

Split third-party libraries:

```typescript
// Split date library (moment.js, date-fns, etc.)
const DatePicker = lazy(() =>
  import('react-datepicker').then((module) => ({
    default: module.default,
  }))
);

// Split markdown renderer
const MarkdownPreview = lazy(() => import('./MarkdownPreview'));
```

---

## Memoization Strategies

### 1. React.memo

Prevent re-renders of expensive components:

```typescript
// ✅ Memoize expensive component
const ExpensiveList = memo(({ items }: { items: Item[] }) => {
  return (
    <ul>
      {items.map((item) => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
});

// Usage - only re-renders if items change
function Parent() {
  const [count, setCount] = useState(0);
  const items = useMemo(() => generateItems(), []);

  return (
    <>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <ExpensiveList items={items} /> {/* Won't re-render on count change */}
    </>
  );
}
```

**When to use React.memo:**
- ✅ Component renders frequently with same props
- ✅ Component is expensive to render
- ✅ Pure component (output depends only on props)

**When NOT to use:**
- ❌ Premature optimization (profile first!)
- ❌ Component rarely re-renders
- ❌ Props change frequently anyway

### 2. useMemo

Memoize expensive calculations:

```typescript
function SearchResults({ query, items }: Props) {
  // ✅ Memoize expensive filtering
  const filteredItems = useMemo(() => {
    console.log('Filtering...'); // Only logs when query or items change
    return items.filter((item) =>
      item.name.toLowerCase().includes(query.toLowerCase())
    );
  }, [query, items]);

  return <List items={filteredItems} />;
}

// ❌ Avoid: Unnecessary memoization
const doubled = useMemo(() => count * 2, [count]); // Simple calculation, no benefit
```

### 3. useCallback

Memoize function references:

```typescript
function Parent() {
  const [count, setCount] = useState(0);

  // ✅ Memoize callback passed to memoized child
  const handleItemClick = useCallback((id: string) => {
    console.log('Item clicked:', id);
    // Do something with id
  }, []); // No dependencies

  return (
    <>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <MemoizedList onItemClick={handleItemClick} />
    </>
  );
}

const MemoizedList = memo(({ onItemClick }: { onItemClick: (id: string) => void }) => {
  // Won't re-render because onItemClick reference is stable
  return <div>...</div>;
});
```

**When to use useCallback:**
- ✅ Function passed to memoized child
- ✅ Function used in dependency array
- ✅ Function creates expensive operation

**When NOT to use:**
- ❌ Function not passed to children
- ❌ Child not memoized
- ❌ Premature optimization

---

## Virtual Scrolling

For long lists (1000+ items), use virtual scrolling:

### Using react-window

```typescript
import { FixedSizeList } from 'react-window';

interface Item {
  id: string;
  name: string;
}

function VirtualList({ items }: { items: Item[] }) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      {items[index].name}
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

### Using react-virtuoso (More flexible)

```typescript
import { Virtuoso } from 'react-virtuoso';

function VirtualList({ items }: { items: Item[] }) {
  return (
    <Virtuoso
      style={{ height: '600px' }}
      data={items}
      itemContent={(index, item) => (
        <div key={item.id}>{item.name}</div>
      )}
    />
  );
}
```

**Benefits:**
- ✅ Only render visible items (~20-30)
- ✅ Smooth scrolling with 10,000+ items
- ✅ Reduces DOM nodes significantly

---

## Bundle Optimization

### 1. Analyze Bundle Size

```bash
# Using webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer

# Add to webpack config
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin()
  ]
}

# For Vite
npm install --save-dev rollup-plugin-visualizer
```

### 2. Tree Shaking

Import only what you need:

```typescript
// ✅ Good: Named imports (tree-shakeable)
import { debounce, throttle } from 'lodash-es';

// ❌ Avoid: Default import (imports entire library)
import _ from 'lodash';
_.debounce(fn, 300);

// ✅ Good: Specific imports
import debounce from 'lodash-es/debounce';
```

### 3. Dynamic Imports

```typescript
// ✅ Load heavy library on demand
async function exportToExcel(data: any[]) {
  const XLSX = await import('xlsx');
  const worksheet = XLSX.utils.json_to_sheet(data);
  // ... export logic
}

// ✅ Feature flags with code splitting
if (process.env.ENABLE_ANALYTICS) {
  import('./analytics').then(({ init }) => init());
}
```

### 4. Dependency Optimization

```typescript
// vite.config.ts
export default defineConfig({
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom'],
    exclude: ['@my-local/package']
  }
});
```

---

## Image Optimization

### 1. Modern Image Formats

```typescript
// ✅ Use WebP with fallback
<picture>
  <source srcSet="image.webp" type="image/webp" />
  <source srcSet="image.jpg" type="image/jpeg" />
  <img src="image.jpg" alt="Description" />
</picture>

// ✅ Next.js automatic optimization
import Image from 'next/image';

<Image
  src="/photo.jpg"
  width={800}
  height={600}
  alt="Photo"
  placeholder="blur" // Automatic blur-up
/>
```

### 2. Responsive Images

```typescript
// ✅ Serve appropriate size for device
<img
  srcSet="
    small.jpg 400w,
    medium.jpg 800w,
    large.jpg 1200w
  "
  sizes="(max-width: 400px) 400px, (max-width: 800px) 800px, 1200px"
  src="medium.jpg"
  alt="Responsive image"
/>
```

### 3. Lazy Loading

```typescript
// ✅ Native lazy loading
<img src="image.jpg" loading="lazy" alt="Lazy loaded" />

// ✅ Intersection Observer for custom lazy loading
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [imageSrc, setImageSrc] = useState<string | null>(null);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setImageSrc(src);
          observer.disconnect();
        }
      },
      { rootMargin: '50px' }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, [src]);

  return <img ref={imgRef} src={imageSrc || undefined} alt={alt} />;
}
```

---

## Performance Monitoring

### 1. React DevTools Profiler

```typescript
import { Profiler } from 'react';

function onRenderCallback(
  id: string,
  phase: 'mount' | 'update',
  actualDuration: number,
  baseDuration: number,
  startTime: number,
  commitTime: number
) {
  console.log(`${id} (${phase}) took ${actualDuration}ms`);
}

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}
```

### 2. Web Vitals Tracking

```typescript
import { onCLS, onFID, onLCP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics({ name, value, id }: Metric) {
  // Send to your analytics service
  console.log(name, value);
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

### 3. Performance API

```typescript
// Measure custom metrics
performance.mark('start-render');
// ... rendering logic
performance.mark('end-render');
performance.measure('render-time', 'start-render', 'end-render');

const measure = performance.getEntriesByName('render-time')[0];
console.log('Render took:', measure.duration, 'ms');
```

---

## Summary Checklist

- ✅ Optimize Core Web Vitals (LCP < 2.5s, FID < 100ms, CLS < 0.1)
- ✅ Code-split by routes and heavy components
- ✅ Use React.memo, useMemo, useCallback strategically (not everywhere!)
- ✅ Implement virtual scrolling for long lists (1000+ items)
- ✅ Analyze bundle size and remove unused dependencies
- ✅ Use tree-shaking with named imports
- ✅ Optimize images (WebP, lazy loading, responsive)
- ✅ Monitor performance with Web Vitals and Profiler
- ✅ Profile before optimizing (avoid premature optimization)

**Remember**: Profile first, optimize second. Don't guess where the bottleneck is!
