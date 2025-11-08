# Accessibility (a11y)

Comprehensive guide to building accessible React applications following WCAG 2.1 guidelines.

## Core Principles

1. **Perceivable**: Information must be presentable to users
2. **Operable**: UI must be operable by all users
3. **Understandable**: Information and operation must be understandable
4. **Robust**: Content must work with assistive technologies

## Semantic HTML

```typescript
// ✅ Good: Semantic elements
<nav>
  <ul>
    <li><a href="/home">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<main>
  <article>
    <h1>Title</h1>
    <p>Content</p>
  </article>
</main>

<footer>
  <p>© 2024</p>
</footer>

// ❌ Avoid: Div soup
<div>
  <div><div onClick={goHome}>Home</div></div>
  <div>
    <div>
      <div>Title</div>
      <div>Content</div>
    </div>
  </div>
</div>
```

## ARIA Attributes

```typescript
// Button with icon
<button aria-label="Close dialog" onClick={onClose}>
  <X Icon aria-hidden="true" />
</button>

// Loading state
<button aria-busy={isLoading} disabled={isLoading}>
  {isLoading ? 'Loading...' : 'Submit'}
</button>

// Toggle button
<button
  role="switch"
  aria-checked={isEnabled}
  onClick={toggleEnabled}
>
  {isEnabled ? 'Enabled' : 'Disabled'}
</button>

// Tab panel
<div role="tabpanel" aria-labelledby="tab-1" id="panel-1">
  Content
</div>
```

## Keyboard Navigation

```typescript
function Modal({ isOpen, onClose, children }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!isOpen) return;

    // Trap focus inside modal
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }

      if (e.key === 'Tab') {
        const focusableElements = modalRef.current?.querySelectorAll(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );

        if (!focusableElements?.length) return;

        const first = focusableElements[0] as HTMLElement;
        const last = focusableElements[focusableElements.length - 1] as HTMLElement;

        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      {children}
    </div>
  );
}
```

## Form Accessibility

```typescript
function AccessibleForm() {
  const [errors, setErrors] = useState<Record<string, string>>({});

  return (
    <form aria-label="Contact form">
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          aria-required="true"
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <span id="email-error" role="alert" aria-live="polite">
            {errors.email}
          </span>
        )}
      </div>

      <button type="submit">Submit</button>
    </form>
  );
}
```

## Color Contrast

```css
/* ✅ Good: WCAG AA compliant (4.5:1 for normal text) */
.text {
  color: #333333; /* on white background */
}

/* ❌ Avoid: Poor contrast */
.text {
  color: #cccccc; /* on white background - fails WCAG */
}
```

## Focus Management

```typescript
function AutoFocusInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} aria-label="Search" />;
}

// Focus visible styles
const StyledButton = styled.button`
  &:focus-visible {
    outline: 2px solid #0066cc;
    outline-offset: 2px;
  }
`;
```

## Testing Accessibility

```typescript
import { render, screen } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('component is accessible', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});

// Test keyboard navigation
test('can be navigated with keyboard', async () => {
  render(<Menu />);

  const firstItem = screen.getByRole('menuitem', { name: /first/i });
  firstItem.focus();

  fireEvent.keyDown(firstItem, { key: 'ArrowDown' });

  expect(screen.getByRole('menuitem', { name: /second/i })).toHaveFocus();
});
```

## Checklist

- ✅ Use semantic HTML elements
- ✅ Provide alt text for images
- ✅ Ensure keyboard navigation works
- ✅ Maintain 4.5:1 color contrast ratio
- ✅ Add ARIA labels where needed
- ✅ Test with screen readers
- ✅ Support focus visible styles
- ✅ Provide skip links for navigation
- ✅ Ensure forms have proper labels and error messages
- ✅ Test with automated tools (axe, Lighthouse)
