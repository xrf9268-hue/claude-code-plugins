# Testing Strategy

Comprehensive guide to testing React applications with Jest, React Testing Library, and E2E frameworks.

## Testing Philosophy

**Test behavior, not implementation**

```typescript
// ✅ Good: Test what user sees
test('user can submit form with valid data', async () => {
  render(<ContactForm />);

  await userEvent.type(screen.getByLabelText(/name/i), 'John');
  await userEvent.type(screen.getByLabelText(/email/i), 'john@example.com');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  expect(await screen.findByText(/success/i)).toBeInTheDocument();
});

// ❌ Avoid: Test implementation details
test('setState is called with correct value', () => {
  const setState = jest.fn();
  useState.mockReturnValue(['', setState]);
  // Don't test internal state management
});
```

## Unit Testing with React Testing Library

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  test('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  test('calls onClick when clicked', async () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click</Button>);

    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('shows loading state', () => {
    render(<Button loading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });
});
```

## Testing Hooks

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useUser } from './useUser';

test('useUser fetches and returns user data', async () => {
  const { result } = renderHook(() => useUser('123'));

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.user).toEqual({ id: '123', name: 'John' });
});
```

## Mocking API Calls

```typescript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(ctx.json({ id: req.params.id, name: 'John' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('displays user data', async () => {
  render(<UserProfile userId="123" />);

  expect(await screen.findByText('John')).toBeInTheDocument();
});
```

## Integration Testing

```typescript
test('complete user flow', async () => {
  render(<App />);

  // Navigate
  await userEvent.click(screen.getByRole('link', { name: /login/i }));

  // Fill form
  await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
  await userEvent.type(screen.getByLabelText(/password/i), 'password123');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  // Verify redirect and content
  expect(await screen.findByText(/welcome/i)).toBeInTheDocument();
  expect(screen.getByRole('button', { name: /logout/i })).toBeInTheDocument();
});
```

## E2E Testing with Playwright

```typescript
import { test, expect } from '@playwright/test';

test('user can complete checkout flow', async ({ page }) => {
  await page.goto('/products');

  // Add to cart
  await page.getByRole('button', { name: 'Add to cart' }).first().click();

  // Go to checkout
  await page.getByRole('link', { name: 'Cart' }).click();
  await page.getByRole('button', { name: 'Checkout' }).click();

  // Fill shipping info
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Address').fill('123 Main St');
  await page.getByRole('button', { name: 'Continue' }).click();

  // Verify order summary
  await expect(page.getByRole('heading', { name: 'Order Summary' })).toBeVisible();
});
```

## Testing Best Practices

- ✅ Test user behavior, not implementation
- ✅ Use accessible queries (getByRole, getByLabelText)
- ✅ Mock external dependencies
- ✅ Test error states and edge cases
- ✅ Use async utilities for asynchronous updates
- ✅ Write descriptive test names
- ✅ Avoid testing third-party libraries
- ✅ Maintain test independence (no shared state)
