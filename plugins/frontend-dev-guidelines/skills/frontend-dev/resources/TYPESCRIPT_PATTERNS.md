# TypeScript Patterns for React

This resource covers TypeScript best practices specifically for React applications, including component typing, hooks, generics, and utility types.

## Table of Contents

1. [Component Typing](#component-typing)
2. [Props Patterns](#props-patterns)
3. [Hooks Typing](#hooks-typing)
4. [Event Handlers](#event-handlers)
5. [Refs and DOM](#refs-and-dom)
6. [Generic Components](#generic-components)
7. [Utility Types](#utility-types)
8. [Advanced Patterns](#advanced-patterns)

---

## Component Typing

### 1. Function Components

**✅ Recommended: Explicit types**

```typescript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

// Option 1: Type props directly
function Button({ label, onClick, variant = 'primary', disabled }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled} className={variant}>
      {label}
    </button>
  );
}

// Option 2: React.FC (includes children automatically)
const Button: React.FC<ButtonProps> = ({ label, onClick, variant = 'primary', disabled }) => {
  return (
    <button onClick={onClick} disabled={disabled} className={variant}>
      {label}
    </button>
  );
};
```

**Note on React.FC:**
- ✅ Pro: Automatically includes `children` prop
- ✅ Pro: Explicit return type checking
- ⚠️ Con: Deprecated in some style guides (children should be explicit)

**Modern Recommendation:**

```typescript
interface ButtonProps {
  label: string;
  onClick: () => void;
  children?: React.ReactNode; // Explicit when needed
}

function Button({ label, onClick, children }: ButtonProps) {
  return <button onClick={onClick}>{children || label}</button>;
}
```

### 2. Component with Children

```typescript
interface CardProps {
  title: string;
  children: React.ReactNode; // Explicit children type
}

function Card({ title, children }: CardProps) {
  return (
    <div>
      <h2>{title}</h2>
      <div>{children}</div>
    </div>
  );
}
```

**Children type options:**

```typescript
// Most permissive (recommended)
children: React.ReactNode

// Only single element
children: React.ReactElement

// Multiple elements
children: React.ReactElement[]

// Render function pattern
children: (data: T) => React.ReactNode
```

---

## Props Patterns

### 1. Optional vs Required Props

```typescript
interface UserCardProps {
  // Required props
  userId: string;
  name: string;

  // Optional props
  email?: string;
  avatarUrl?: string;

  // Optional with default
  variant?: 'compact' | 'expanded';
}

function UserCard({
  userId,
  name,
  email,
  avatarUrl,
  variant = 'compact', // Default value
}: UserCardProps) {
  // Implementation
}
```

### 2. Extending HTML Attributes

Extend native HTML attributes for better type safety:

```typescript
// Extend button attributes
interface CustomButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant: 'primary' | 'secondary';
  loading?: boolean;
}

function CustomButton({ variant, loading, children, ...restProps }: CustomButtonProps) {
  return (
    <button {...restProps} className={variant} disabled={loading || restProps.disabled}>
      {loading ? 'Loading...' : children}
    </button>
  );
}

// Usage: All standard button props work!
<CustomButton variant="primary" onClick={handleClick} type="submit" aria-label="Save">
  Save
</CustomButton>
```

**Common HTML attribute types:**

```typescript
React.ButtonHTMLAttributes<HTMLButtonElement>
React.InputHTMLAttributes<HTMLInputElement>
React.FormHTMLAttributes<HTMLFormElement>
React.HTMLAttributes<HTMLDivElement>
React.AnchorHTMLAttributes<HTMLAnchorElement>
```

### 3. Union Props (Discriminated Unions)

When props are mutually exclusive:

```typescript
// ✅ Good: Discriminated union
type AlertProps =
  | {
      type: 'success';
      message: string;
      onClose: () => void;
    }
  | {
      type: 'error';
      message: string;
      retryAction: () => void;
      onClose: () => void;
    }
  | {
      type: 'info';
      message: string;
    };

function Alert(props: AlertProps) {
  switch (props.type) {
    case 'success':
      return (
        <div className="success">
          {props.message}
          <button onClick={props.onClose}>Close</button>
        </div>
      );
    case 'error':
      return (
        <div className="error">
          {props.message}
          <button onClick={props.retryAction}>Retry</button>
          <button onClick={props.onClose}>Close</button>
        </div>
      );
    case 'info':
      return <div className="info">{props.message}</div>;
  }
}
```

---

## Hooks Typing

### 1. useState

```typescript
// Type inference works
const [count, setCount] = useState(0); // number
const [name, setName] = useState(''); // string

// Explicit type when needed
const [user, setUser] = useState<User | null>(null);

// Complex initial state
interface FormState {
  email: string;
  password: string;
  remember: boolean;
}

const [form, setForm] = useState<FormState>({
  email: '',
  password: '',
  remember: false,
});
```

### 2. useRef

```typescript
// DOM refs
const inputRef = useRef<HTMLInputElement>(null);

// Usage
useEffect(() => {
  inputRef.current?.focus(); // Optional chaining for safety
}, []);

// Mutable value refs
const counterRef = useRef<number>(0);

// Usage
const handleClick = () => {
  counterRef.current += 1;
  console.log(counterRef.current);
};
```

### 3. useReducer

```typescript
// State and action types
interface State {
  count: number;
  error: string | null;
}

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'reset' }
  | { type: 'set_error'; payload: string };

// Reducer function
function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1 };
    case 'decrement':
      return { ...state, count: state.count - 1 };
    case 'reset':
      return { ...state, count: 0 };
    case 'set_error':
      return { ...state, error: action.payload };
    default:
      return state;
  }
}

// Usage
function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, error: null });

  return (
    <>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
    </>
  );
}
```

### 4. useContext

```typescript
// Define context type
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

// Create context with undefined default (will be provided by Provider)
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Custom hook for consuming context
function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Provider component
function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Usage in component
function ThemedButton() {
  const { theme, toggleTheme } = useTheme();

  return <button onClick={toggleTheme}>Current: {theme}</button>;
}
```

### 5. Custom Hook Typing

```typescript
// Custom hook with return type
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const; // as const for tuple type
}

// Usage
function App() {
  const [name, setName] = useLocalStorage<string>('name', 'Guest');
  const [settings, setSettings] = useLocalStorage<UserSettings>('settings', defaultSettings);

  return <div>{name}</div>;
}
```

---

## Event Handlers

### 1. Common Event Types

```typescript
function Form() {
  // Input change
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    console.log(event.target.value);
  };

  // Form submit
  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    // Handle submission
  };

  // Button click
  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    console.log('Clicked at:', event.clientX, event.clientY);
  };

  // Keyboard events
  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      console.log('Enter pressed');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleChange} onKeyDown={handleKeyDown} />
      <button onClick={handleClick}>Submit</button>
    </form>
  );
}
```

### 2. Generic Event Handlers

```typescript
// Reusable handler type
type InputChangeHandler = (event: React.ChangeEvent<HTMLInputElement>) => void;

interface FormProps {
  onEmailChange: InputChangeHandler;
  onPasswordChange: InputChangeHandler;
}

function LoginForm({ onEmailChange, onPasswordChange }: FormProps) {
  return (
    <>
      <input type="email" onChange={onEmailChange} />
      <input type="password" onChange={onPasswordChange} />
    </>
  );
}
```

---

## Refs and DOM

### 1. Typed Refs

```typescript
function TextInput() {
  const inputRef = useRef<HTMLInputElement>(null);
  const divRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const focusInput = () => {
    inputRef.current?.focus(); // Safe with optional chaining
  };

  const getButtonText = () => {
    return buttonRef.current?.textContent; // string | undefined
  };

  return (
    <div ref={divRef}>
      <input ref={inputRef} />
      <button ref={buttonRef} onClick={focusInput}>
        Focus Input
      </button>
    </div>
  );
}
```

### 2. ForwardRef with TypeScript

```typescript
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
}

// forwardRef with generic types
const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, ...props }, ref) => {
    return (
      <div>
        <label>{label}</label>
        <input ref={ref} {...props} />
      </div>
    );
  }
);

Input.displayName = 'Input'; // For debugging

// Usage
function Form() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <Input ref={inputRef} label="Name" />;
}
```

---

## Generic Components

### 1. List Component with Generics

```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string | number;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage
interface User {
  id: number;
  name: string;
}

function App() {
  const users: User[] = [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
  ];

  return (
    <List
      items={users}
      renderItem={(user) => <span>{user.name}</span>}
      keyExtractor={(user) => user.id}
    />
  );
}
```

### 2. Select Component with Generics

```typescript
interface SelectProps<T> {
  options: T[];
  value: T;
  onChange: (value: T) => void;
  getLabel: (option: T) => string;
  getValue: (option: T) => string | number;
}

function Select<T>({ options, value, onChange, getLabel, getValue }: SelectProps<T>) {
  return (
    <select
      value={getValue(value)}
      onChange={(e) => {
        const selected = options.find((opt) => getValue(opt) === e.target.value);
        if (selected) onChange(selected);
      }}
    >
      {options.map((option) => (
        <option key={getValue(option)} value={getValue(option)}>
          {getLabel(option)}
        </option>
      ))}
    </select>
  );
}

// Usage
interface Country {
  code: string;
  name: string;
}

const countries: Country[] = [
  { code: 'US', name: 'United States' },
  { code: 'CA', name: 'Canada' },
];

function CountrySelector() {
  const [selected, setSelected] = useState(countries[0]);

  return (
    <Select
      options={countries}
      value={selected}
      onChange={setSelected}
      getLabel={(c) => c.name}
      getValue={(c) => c.code}
    />
  );
}
```

---

## Utility Types

### 1. React Utility Types

```typescript
// Extract props from a component
type ButtonProps = React.ComponentProps<typeof Button>;

// Extract element type
type DivProps = React.ComponentPropsWithoutRef<'div'>;
type InputProps = React.ComponentPropsWithRef<'input'>;

// CSS Properties
const style: React.CSSProperties = {
  color: 'red',
  fontSize: 16,
  display: 'flex',
};
```

### 2. Custom Utility Types

```typescript
// Make all props optional
type PartialProps<T> = {
  [P in keyof T]?: T[P];
};

// Pick subset of props
type SubsetProps = Pick<UserCardProps, 'userId' | 'name'>;

// Omit certain props
type WithoutEmail = Omit<UserCardProps, 'email'>;

// Make specific props required
type RequiredEmail = Required<Pick<UserCardProps, 'email'>> &
  Omit<UserCardProps, 'email'>;
```

### 3. Props Composition

```typescript
// Base props
interface BaseProps {
  id: string;
  className?: string;
}

// Extend base props
interface UserProps extends BaseProps {
  user: User;
  onUpdate: (user: User) => void;
}

// Compose multiple interfaces
interface CardProps extends BaseProps, React.HTMLAttributes<HTMLDivElement> {
  title: string;
  children: React.ReactNode;
}
```

---

## Advanced Patterns

### 1. Render Props with TypeScript

```typescript
interface MouseTrackerProps {
  children: (position: { x: number; y: number }) => React.ReactNode;
}

function MouseTracker({ children }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);

  return <>{children(position)}</>;
}

// Usage
function App() {
  return (
    <MouseTracker>
      {({ x, y }) => (
        <div>
          Mouse at: {x}, {y}
        </div>
      )}
    </MouseTracker>
  );
}
```

### 2. Higher-Order Components (HOC)

```typescript
// HOC that adds loading prop
function withLoading<P extends object>(
  Component: React.ComponentType<P>
): React.FC<P & { loading: boolean }> {
  return ({ loading, ...props }: P & { loading: boolean }) => {
    if (loading) return <div>Loading...</div>;
    return <Component {...(props as P)} />;
  };
}

// Usage
interface UserProfileProps {
  user: User;
}

function UserProfile({ user }: UserProfileProps) {
  return <div>{user.name}</div>;
}

const UserProfileWithLoading = withLoading(UserProfile);

// Use with loading prop
<UserProfileWithLoading user={user} loading={isLoading} />
```

### 3. Polymorphic Components

Components that can render as different elements:

```typescript
type AsProp<C extends React.ElementType> = {
  as?: C;
};

type PropsToOmit<C extends React.ElementType, P> = keyof (AsProp<C> & P);

type PolymorphicComponentProp<
  C extends React.ElementType,
  Props = {}
> = React.PropsWithChildren<Props & AsProp<C>> &
  Omit<React.ComponentPropsWithoutRef<C>, PropsToOmit<C, Props>>;

interface TextProps {
  color?: string;
  size?: 'sm' | 'md' | 'lg';
}

function Text<C extends React.ElementType = 'span'>({
  as,
  color,
  size = 'md',
  children,
  ...restProps
}: PolymorphicComponentProp<C, TextProps>) {
  const Component = as || 'span';
  return (
    <Component style={{ color }} className={size} {...restProps}>
      {children}
    </Component>
  );
}

// Usage - can be any element!
<Text as="h1" size="lg">Heading</Text>
<Text as="p" color="blue">Paragraph</Text>
<Text as="a" href="/home">Link</Text>
```

---

## Summary Checklist

When typing React components with TypeScript:

- ✅ Explicitly type props interfaces
- ✅ Use `React.ReactNode` for children (most flexible)
- ✅ Extend HTML attributes for native element wrappers
- ✅ Use discriminated unions for exclusive props
- ✅ Type event handlers with React event types
- ✅ Use `useRef<HTMLElement>(null)` for DOM refs
- ✅ Create generic components for reusable patterns
- ✅ Leverage utility types (Pick, Omit, Required, etc.)
- ✅ Type custom hooks with proper return types
- ✅ Use `as const` for tuple returns in hooks

TypeScript + React provides excellent type safety and developer experience. Use it to its full potential!
