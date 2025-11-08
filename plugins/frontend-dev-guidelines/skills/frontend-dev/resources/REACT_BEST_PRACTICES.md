# React Best Practices

This resource covers modern React patterns and best practices for React 18+, focusing on function components, hooks, and concurrent features.

## Table of Contents

1. [Function Components and Hooks](#function-components-and-hooks)
2. [Component Lifecycle Patterns](#component-lifecycle-patterns)
3. [Concurrent Features](#concurrent-features)
4. [Common Pitfalls](#common-pitfalls)
5. [Advanced Patterns](#advanced-patterns)

---

## Function Components and Hooks

### 1. Always Use Function Components

React 18+ is designed around function components and hooks. Class components are legacy.

**✅ Recommended:**

```typescript
interface UserProfileProps {
  userId: string;
}

function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <Skeleton />;
  if (!user) return <NotFound />;

  return <div>{user.name}</div>;
}
```

**❌ Avoid:**

```typescript
// Class components are legacy
class UserProfile extends React.Component<Props, State> {
  // Don't use unless maintaining legacy code
}
```

### 2. Custom Hooks for Reusable Logic

Extract reusable logic into custom hooks. This promotes code reuse and testability.

**✅ Recommended:**

```typescript
// Custom hook for data fetching
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading, error };
}

// Usage
function UserProfile({ userId }: { userId: string }) {
  const { user, loading, error } = useUser(userId);

  if (loading) return <Skeleton />;
  if (error) return <ErrorDisplay error={error} />;
  if (!user) return <NotFound />;

  return <UserCard user={user} />;
}
```

**Benefits:**
- ✅ Logic is testable independently
- ✅ Easy to reuse across components
- ✅ Separates concerns clearly
- ✅ Easier to refactor

### 3. Rules of Hooks

**Always follow these rules:**

1. **Only call hooks at the top level** (never in loops, conditions, or nested functions)
2. **Only call hooks from React functions** (components or custom hooks)

**✅ Correct:**

```typescript
function MyComponent() {
  const [count, setCount] = useState(0);

  if (count > 10) {
    // ✅ Conditional logic AFTER hook call
    return <div>Count is high</div>;
  }

  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

**❌ Wrong:**

```typescript
function MyComponent() {
  if (someCondition) {
    const [count, setCount] = useState(0); // ❌ Conditional hook call
  }

  return <div>...</div>;
}
```

### 4. useState Best Practices

**Functional Updates:**

```typescript
// ✅ Good: Functional update when depending on previous state
setCount((prevCount) => prevCount + 1);

// ❌ Avoid: Direct update (can miss updates in async scenarios)
setCount(count + 1);
```

**Lazy Initialization:**

```typescript
// ✅ Good: Expensive computation only runs once
const [data, setData] = useState(() => {
  return expensiveComputation();
});

// ❌ Avoid: Runs on every render
const [data, setData] = useState(expensiveComputation());
```

**Object State Updates:**

```typescript
// ✅ Good: Spread operator for immutability
setUser((prevUser) => ({
  ...prevUser,
  name: 'New Name',
}));

// ❌ Avoid: Direct mutation
user.name = 'New Name';
setUser(user);
```

### 5. useEffect Best Practices

**Include All Dependencies:**

```typescript
// ✅ Good: All dependencies listed
useEffect(() => {
  fetchData(userId, filter);
}, [userId, filter]);

// ❌ Avoid: Missing dependencies (ESLint will warn)
useEffect(() => {
  fetchData(userId, filter);
}, []); // Missing userId and filter!
```

**Cleanup Functions:**

```typescript
// ✅ Good: Cleanup subscriptions
useEffect(() => {
  const subscription = dataSource.subscribe(handleData);

  return () => {
    subscription.unsubscribe();
  };
}, [dataSource]);
```

**Avoid Unnecessary Effects:**

```typescript
// ❌ Avoid: Effect for derived state
const [count, setCount] = useState(0);
const [doubled, setDoubled] = useState(0);

useEffect(() => {
  setDoubled(count * 2);
}, [count]);

// ✅ Good: Direct calculation
const [count, setCount] = useState(0);
const doubled = count * 2;
```

---

## Component Lifecycle Patterns

### 1. Mounting (First Render)

```typescript
function MyComponent() {
  useEffect(() => {
    // Runs once after first render
    console.log('Component mounted');

    return () => {
      // Cleanup when component unmounts
      console.log('Component unmounting');
    };
  }, []); // Empty dependency array = run once

  return <div>Hello</div>;
}
```

### 2. Updating (On Prop/State Change)

```typescript
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    // Runs on mount AND when userId changes
    console.log('Fetching user:', userId);
    fetchUser(userId).then(setUser);
  }, [userId]); // Dependency array with userId

  return <div>{user?.name}</div>;
}
```

### 3. Unmounting (Cleanup)

```typescript
function Timer() {
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds((s) => s + 1);
    }, 1000);

    // Cleanup function runs on unmount
    return () => {
      clearInterval(interval);
    };
  }, []);

  return <div>{seconds}s</div>;
}
```

---

## Concurrent Features

React 18 introduced concurrent features for better UX. Use these for optimal performance.

### 1. Suspense for Data Fetching

```typescript
// ✅ Modern: Suspense boundary
import { Suspense } from 'react';

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <UserProfile userId="123" />
    </Suspense>
  );
}

// Component can "suspend" during data fetching
function UserProfile({ userId }: { userId: string }) {
  const user = use(fetchUser(userId)); // React 19+ use() hook
  return <div>{user.name}</div>;
}
```

**Benefits:**
- ✅ Declarative loading states
- ✅ Prevents loading UI flicker
- ✅ Better perceived performance

### 2. useTransition for Non-Urgent Updates

```typescript
import { useState, useTransition } from 'react';

function SearchResults() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  const handleSearch = (value: string) => {
    setQuery(value); // Urgent: update input immediately

    startTransition(() => {
      // Non-urgent: search can be interrupted
      const filtered = heavySearch(value);
      setResults(filtered);
    });
  };

  return (
    <>
      <input value={query} onChange={(e) => handleSearch(e.target.value)} />
      {isPending && <span>Searching...</span>}
      <Results data={results} />
    </>
  );
}
```

**When to use:**
- ✅ Heavy computations that can be delayed
- ✅ Navigation that can show stale UI momentarily
- ✅ Expensive filtering/sorting

### 3. useDeferredValue for Debouncing

```typescript
import { useState, useDeferredValue, useMemo } from 'react';

function SearchResults() {
  const [query, setQuery] = useState('');

  // Defer expensive operation
  const deferredQuery = useDeferredValue(query);

  const results = useMemo(() => {
    return heavySearch(deferredQuery);
  }, [deferredQuery]);

  return (
    <>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <Results data={results} />
    </>
  );
}
```

**Difference from useTransition:**
- `useTransition`: Control when to defer
- `useDeferredValue`: Automatically defer a value

---

## Common Pitfalls

### 1. Stale Closures

**Problem:**

```typescript
// ❌ Wrong: count is stale in callback
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      console.log(count); // Always logs 0!
      setCount(count + 1); // Doesn't work as expected
    }, 1000);

    return () => clearInterval(timer);
  }, []); // count not in dependencies

  return <div>{count}</div>;
}
```

**Solution:**

```typescript
// ✅ Good: Use functional update
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setCount((prevCount) => prevCount + 1); // Access current value
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  return <div>{count}</div>;
}
```

### 2. Unnecessary Re-renders

**Problem:**

```typescript
// ❌ Creates new function on every render
function Parent() {
  const handleClick = () => {
    console.log('Clicked');
  };

  return <ExpensiveChild onClick={handleClick} />;
}
```

**Solution:**

```typescript
// ✅ Memoize callback
import { useCallback } from 'react';

function Parent() {
  const handleClick = useCallback(() => {
    console.log('Clicked');
  }, []);

  return <ExpensiveChild onClick={handleClick} />;
}

const ExpensiveChild = memo(({ onClick }: { onClick: () => void }) => {
  // Won't re-render unless onClick changes
  return <button onClick={onClick}>Click</button>;
});
```

### 3. Missing Key Prop in Lists

**Problem:**

```typescript
// ❌ Using index as key
{items.map((item, index) => (
  <Item key={index} data={item} />
))}
```

**Why it's bad:**
- Breaks when list is reordered
- Can cause state to persist incorrectly
- Hurts performance

**Solution:**

```typescript
// ✅ Use stable, unique identifier
{items.map((item) => (
  <Item key={item.id} data={item} />
))}
```

### 4. Side Effects in Render

**Problem:**

```typescript
// ❌ Side effect during render
function Component() {
  localStorage.setItem('viewed', 'true'); // Wrong place!
  return <div>Content</div>;
}
```

**Solution:**

```typescript
// ✅ Side effects in useEffect
function Component() {
  useEffect(() => {
    localStorage.setItem('viewed', 'true');
  }, []);

  return <div>Content</div>;
}
```

---

## Advanced Patterns

### 1. useReducer for Complex State

When state logic is complex, prefer `useReducer` over multiple `useState` calls.

```typescript
type State = {
  user: User | null;
  loading: boolean;
  error: Error | null;
};

type Action =
  | { type: 'FETCH_START' }
  | { type: 'FETCH_SUCCESS'; payload: User }
  | { type: 'FETCH_ERROR'; payload: Error };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };
    case 'FETCH_SUCCESS':
      return { user: action.payload, loading: false, error: null };
    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };
    default:
      return state;
  }
}

function UserProfile({ userId }: { userId: string }) {
  const [state, dispatch] = useReducer(reducer, {
    user: null,
    loading: false,
    error: null,
  });

  useEffect(() => {
    dispatch({ type: 'FETCH_START' });
    fetchUser(userId)
      .then((user) => dispatch({ type: 'FETCH_SUCCESS', payload: user }))
      .catch((error) => dispatch({ type: 'FETCH_ERROR', payload: error }));
  }, [userId]);

  // Render based on state
}
```

### 2. useImperativeHandle with forwardRef

Expose imperative methods to parent components (use sparingly).

```typescript
import { useImperativeHandle, forwardRef, useRef } from 'react';

interface VideoPlayerHandle {
  play: () => void;
  pause: () => void;
}

const VideoPlayer = forwardRef<VideoPlayerHandle, { src: string }>(
  ({ src }, ref) => {
    const videoRef = useRef<HTMLVideoElement>(null);

    useImperativeHandle(ref, () => ({
      play() {
        videoRef.current?.play();
      },
      pause() {
        videoRef.current?.pause();
      },
    }));

    return <video ref={videoRef} src={src} />;
  }
);

// Usage
function App() {
  const playerRef = useRef<VideoPlayerHandle>(null);

  return (
    <>
      <VideoPlayer ref={playerRef} src="video.mp4" />
      <button onClick={() => playerRef.current?.play()}>Play</button>
    </>
  );
}
```

### 3. Error Boundaries

Catch errors in component tree (must use class component for now).

```typescript
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback: ReactNode;
}

interface State {
  hasError: boolean;
}

class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }

    return this.props.children;
  }
}

// Usage
function App() {
  return (
    <ErrorBoundary fallback={<ErrorFallback />}>
      <MyComponent />
    </ErrorBoundary>
  );
}
```

---

## Summary Checklist

When writing React components, ensure:

- ✅ Use function components, not classes
- ✅ Follow Rules of Hooks (top level, React functions only)
- ✅ Include all dependencies in useEffect
- ✅ Use functional updates in setState when needed
- ✅ Cleanup effects (unsubscribe, clear timers)
- ✅ Use unique, stable keys in lists (not index)
- ✅ Avoid side effects during render
- ✅ Leverage concurrent features (Suspense, transitions)
- ✅ Extract reusable logic into custom hooks
- ✅ Use useReducer for complex state logic

By following these practices, you'll write maintainable, performant, and bug-free React code.
