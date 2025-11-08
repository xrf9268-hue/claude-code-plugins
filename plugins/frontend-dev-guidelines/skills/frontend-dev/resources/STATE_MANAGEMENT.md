# State Management

Comprehensive guide to state management in React applications, from local state to global state solutions.

## Quick Reference

- **Local state**: useState, useReducer
- **Shared state**: Context API
- **Global state (complex)**: Redux Toolkit, Zustand
- **Server state**: React Query, SWR

## Local State with useState

```typescript
function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}
```

## Context API for Shared State

```typescript
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
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

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
```

## Redux Toolkit (Complex Global State)

```typescript
import { createSlice, configureStore } from '@reduxjs/toolkit';

const counterSlice = createSlice({
  name: 'counter',
  initialState: { value: 0 },
  reducers: {
    increment: (state) => { state.value += 1; },
    decrement: (state) => { state.value -= 1; },
  },
});

export const store = configureStore({
  reducer: { counter: counterSlice.reducer },
});
```

## Zustand (Lightweight Alternative)

```typescript
import create from 'zustand';

interface BearStore {
  bears: number;
  increasePopulation: () => void;
  removeAllBears: () => void;
}

export const useBearStore = create<BearStore>((set) => ({
  bears: 0,
  increasePopulation: () => set((state) => ({ bears: state.bears + 1 })),
  removeAllBears: () => set({ bears: 0 }),
}));

// Usage
function App() {
  const bears = useBearStore((state) => state.bears);
  return <div>Bears: {bears}</div>;
}
```

## React Query (Server State)

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(res => res.json()),
  });
}

function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (user: User) => fetch(`/api/users/${user.id}`, {
      method: 'PUT',
      body: JSON.stringify(user),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
}
```

## When to Use What

- **useState**: Component-local state
- **useReducer**: Complex component state with multiple actions
- **Context**: Theme, auth, i18n (infrequent updates)
- **Redux Toolkit**: Complex app with many interdependent states
- **Zustand**: Simpler alternative to Redux
- **React Query/SWR**: Server data fetching and caching
