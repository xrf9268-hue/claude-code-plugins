# Component Architecture

This resource covers component design patterns, composition strategies, and architectural best practices for React applications.

## Table of Contents

1. [Component Composition](#component-composition)
2. [Props Design](#props-design)
3. [Compound Components](#compound-components)
4. [Container/Presentation Pattern](#containerpresentation-pattern)
5. [Render Props Pattern](#render-props-pattern)

---

## Component Composition

### 1. Composition Over Inheritance

**✅ Recommended: Build with composition**

```typescript
// ✅ Good: Composition
interface Card Props {
  children: React.ReactNode;
}

function Card({ children }: CardProps) {
  return <div className="card">{children}</div>;
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>;
}

function CardBody({ children }: { children: React.ReactNode }) {
  return <div className="card-body">{children}</div>;
}

// Usage: Compose together
<Card>
  <CardHeader>
    <h2>Title</h2>
  </CardHeader>
  <CardBody>
    <p>Content</p>
  </CardBody>
</Card>
```

**❌ Avoid: Deep inheritance**

```typescript
// ❌ Bad: Inheritance hierarchy
class BaseCard extends Component {}
class StyledCard extends BaseCard {}
class AnimatedCard extends StyledCard {}
```

### 2. Component Granularity

Break components into focused, reusable pieces:

```typescript
// ✅ Good: Small, focused components
function UserCard({ user }: { user: User }) {
  return (
    <Card>
      <Avatar src={user.avatar} alt={user.name} />
      <UserInfo name={user.name} email={user.email} />
      <UserActions userId={user.id} />
    </Card>
  );
}

function Avatar({ src, alt }: { src: string; alt: string }) {
  return <img src={src} alt={alt} className="avatar" />;
}

function UserInfo({ name, email }: { name: string; email: string }) {
  return (
    <div>
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  );
}
```

---

## Props Design

### 1. Boolean Props Naming

```typescript
// ✅ Good: Boolean prop names
interface ButtonProps {
  isLoading?: boolean;
  isDisabled?: boolean;
  hasIcon?: boolean;
  // Or without prefix when obvious:
  disabled?: boolean;
  loading?: boolean;
}

// ❌ Avoid: Unclear naming
interface ButtonProps {
  state?: boolean; // What does this mean?
  flag?: boolean; // What flag?
}
```

### 2. Event Handler Props

```typescript
// ✅ Good: Clear event handler naming
interface FormProps {
  onSubmit: (data: FormData) => void;
  onChange: (field: string, value: string) => void;
  onValidationError: (errors: ValidationError[]) => void;
  onCancel?: () => void;
}

// Use consistent prefixes:
// - on* for event handlers
// - handle* for internal methods
function Form({ onSubmit, onChange }: FormProps) {
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onChange(e.target.name, e.target.value);
  };

  return <input onChange={handleInputChange} />;
}
```

### 3. Flexible Props with Variants

```typescript
// ✅ Good: Type-safe variants
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
}

function Button({ variant, size, children }: ButtonProps) {
  const className = `btn btn-${variant} btn-${size}`;
  return <button className={className}>{children}</button>;
}
```

---

## Compound Components

Pattern for components that work together:

```typescript
// ✅ Tabs component with compound pattern
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined);

function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

function TabList({ children }: { children: React.ReactNode }) {
  return <div className="tab-list" role="tablist">{children}</div>;
}

function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab must be used within Tabs');

  const isActive = context.activeTab === id;

  return (
    <button
      role="tab"
      aria-selected={isActive}
      onClick={() => context.setActiveTab(id)}
      className={isActive ? 'tab-active' : 'tab'}
    >
      {children}
    </button>
  );
}

function TabPanel({ id, children }: { id: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabPanel must be used within Tabs');

  if (context.activeTab !== id) return null;

  return <div role="tabpanel">{children}</div>;
}

// Compose sub-components
Tabs.TabList = TabList;
Tabs.Tab = Tab;
Tabs.TabPanel = TabPanel;

// Usage: Intuitive API
<Tabs defaultTab="profile">
  <Tabs.TabList>
    <Tabs.Tab id="profile">Profile</Tabs.Tab>
    <Tabs.Tab id="settings">Settings</Tabs.Tab>
  </Tabs.TabList>

  <Tabs.TabPanel id="profile">
    <ProfileContent />
  </Tabs.TabPanel>
  <Tabs.TabPanel id="settings">
    <SettingsContent />
  </Tabs.TabPanel>
</Tabs>
```

---

## Container/Presentation Pattern

Separate logic from presentation:

```typescript
// ✅ Presentation Component (Dumb/Pure)
interface UserListViewProps {
  users: User[];
  onUserClick: (userId: string) => void;
  loading: boolean;
}

function UserListView({ users, onUserClick, loading }: UserListViewProps) {
  if (loading) return <Skeleton />;

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id} onClick={() => onUserClick(user.id)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}

// ✅ Container Component (Smart)
function UserListContainer() {
  const { users, loading } = useUsers();
  const navigate = useNavigate();

  const handleUserClick = (userId: string) => {
    navigate(`/users/${userId}`);
  };

  return (
    <UserListView
      users={users}
      onUserClick={handleUserClick}
      loading={loading}
    />
  );
}
```

**Benefits:**
- ✅ Presentation components are easy to test (no side effects)
- ✅ Presentation components are reusable (no business logic)
- ✅ Clear separation of concerns
- ✅ Easy to swap data sources

---

## Render Props Pattern

Share logic via render functions:

```typescript
// ✅ Render props for data fetching
interface DataFetcherProps<T> {
  url: string;
  children: (data: T | null, loading: boolean, error: Error | null) => React.ReactNode;
}

function DataFetcher<T>({ url, children }: DataFetcherProps<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetch(url)
      .then((res) => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [url]);

  return <>{children(data, loading, error)}</>;
}

// Usage: Flexible rendering
<DataFetcher<User> url="/api/user">
  {(user, loading, error) => {
    if (loading) return <Spinner />;
    if (error) return <Error message={error.message} />;
    if (!user) return <NotFound />;
    return <UserProfile user={user} />;
  }}
</DataFetcher>
```

**Note:** Modern alternative is custom hooks, which are usually cleaner:

```typescript
// ✅ Modern: Custom hook instead
function useDataFetch<T>(url: string) {
  // ... same logic
  return { data, loading, error };
}

// Usage: Cleaner
function UserProfile() {
  const { data: user, loading, error } = useDataFetch<User>('/api/user');

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  if (!user) return <NotFound />;

  return <div>{user.name}</div>;
}
```

---

## Summary Checklist

- ✅ Prefer composition over inheritance
- ✅ Keep components small and focused
- ✅ Use clear, consistent prop naming (is*, on*, has*)
- ✅ Leverage compound components for related UI
- ✅ Separate container (logic) from presentation (UI)
- ✅ Use custom hooks over render props (modern approach)
- ✅ Design props for flexibility (variants, sizes)
- ✅ Make compound components intuitive to use

Good component architecture leads to maintainable, testable, and reusable code!
