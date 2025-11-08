# Styling Approaches

Guide to different styling methodologies in React applications.

## CSS Modules

```typescript
import styles from './Button.module.css';

function Button() {
  return <button className={styles.button}>Click me</button>;
}
```

**Pros**: Scoped styles, good tooling support
**Cons**: Limited dynamic styling

## Tailwind CSS

```typescript
function Button({ variant }: { variant: 'primary' | 'secondary' }) {
  const baseClasses = 'px-4 py-2 rounded font-semibold';
  const variantClasses = variant === 'primary'
    ? 'bg-blue-500 text-white hover:bg-blue-600'
    : 'bg-gray-200 text-gray-800 hover:bg-gray-300';

  return (
    <button className={`${baseClasses} ${variantClasses}`}>
      Click me
    </button>
  );
}
```

**Pros**: Rapid development, consistent design
**Cons**: Verbose className strings

## Styled-Components (CSS-in-JS)

```typescript
import styled from 'styled-components';

const Button = styled.button<{ variant: 'primary' | 'secondary' }>`
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-weight: 600;
  background-color: ${props => props.variant === 'primary' ? '#3b82f6' : '#e5e7eb'};
  color: ${props => props.variant === 'primary' ? 'white' : '#1f2937'};

  &:hover {
    background-color: ${props => props.variant === 'primary' ? '#2563eb' : '#d1d5db'};
  }
`;

function App() {
  return <Button variant="primary">Click me</Button>;
}
```

**Pros**: Dynamic styles, theming, scoped
**Cons**: Runtime cost, larger bundle

## Material-UI (MUI)

```typescript
import { Button, ThemeProvider, createTheme } from '@mui/material';

const theme = createTheme({
  palette: {
    primary: { main: '#1976d2' },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <Button variant="contained" color="primary">
        Click me
      </Button>
    </ThemeProvider>
  );
}
```

**Pros**: Complete component library, accessible
**Cons**: Opinionated design, bundle size

## Recommendation by Project Type

- **Rapid prototyping**: Tailwind CSS or MUI
- **Design system**: CSS Modules or Styled-Components
- **Performance-critical**: CSS Modules
- **Dynamic theming**: Styled-Components or MUI
