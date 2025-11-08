---
name: frontend-dev
description: Comprehensive React/TypeScript frontend development guidelines covering components, state management, performance, accessibility, and testing. Use when building React components, designing frontend architecture, optimizing performance, implementing TypeScript patterns, or working on modern frontend applications.
---

# Frontend Development Guidelines

## Overview

This skill provides comprehensive guidance for modern frontend development with React, TypeScript, and the broader JavaScript ecosystem. It covers everything from component design to production optimization, helping you build performant, accessible, and maintainable web applications.

**When to use this skill:**
- Building React components
- Designing frontend architecture
- Implementing TypeScript patterns
- Optimizing application performance
- Ensuring accessibility compliance
- Setting up testing strategies
- Configuring build tools
- Working with modern frameworks (Next.js, Vite, etc.)

## Quick Reference

This skill uses a **modular resource structure**. Each topic has detailed guidance in a separate file. When you need specific information, I'll read the relevant resource:

### Core Topics

- 🎯 **React Best Practices** → `./resources/REACT_BEST_PRACTICES.md`
  - Function components and hooks
  - Component lifecycle patterns
  - Concurrent features (Suspense, transitions)
  - Common pitfalls and solutions

- 📦 **Component Architecture** → `./resources/COMPONENT_ARCHITECTURE.md`
  - Component composition patterns
  - Props design and TypeScript integration
  - Compound components
  - Render props and HOCs (when to use)
  - Container/Presentation pattern

- 🎨 **State Management** → `./resources/STATE_MANAGEMENT.md`
  - Local state with useState/useReducer
  - Context API patterns
  - Redux Toolkit
  - Zustand, Jotai alternatives
  - Server state (React Query, SWR)

- 📘 **TypeScript Patterns** → `./resources/TYPESCRIPT_PATTERNS.md`
  - React component typing
  - Hooks typing
  - Generic components
  - Event handlers and refs
  - Utility types for React

- 💅 **Styling Approaches** → `./resources/STYLING_APPROACHES.md`
  - CSS Modules
  - CSS-in-JS (styled-components, emotion)
  - Tailwind CSS
  - Material-UI (MUI)
  - Style organization

- ⚡ **Performance Optimization** → `./resources/PERFORMANCE.md`
  - Code splitting and lazy loading
  - Memoization (React.memo, useMemo, useCallback)
  - Virtual scrolling
  - Bundle optimization
  - Web Vitals and metrics

- ♿ **Accessibility** → `./resources/ACCESSIBILITY.md`
  - WCAG 2.1 guidelines
  - Semantic HTML
  - ARIA attributes
  - Keyboard navigation
  - Screen reader support
  - Testing for accessibility

- 🧪 **Testing Strategy** → `./resources/TESTING.md`
  - Jest configuration
  - React Testing Library patterns
  - Component testing best practices
  - Integration testing
  - E2E with Playwright
  - Visual regression testing

- 🏗️ **Build Optimization** → `./resources/BUILD_OPTIMIZATION.md`
  - Webpack configuration
  - Vite setup and optimization
  - Tree shaking
  - Code splitting strategies
  - Bundle analysis
  - CI/CD considerations

- 🚀 **Modern Frameworks** → `./resources/MODERN_FRAMEWORKS.md`
  - Next.js (App Router, Server Components)
  - Remix patterns
  - Vite project setup
  - Astro for content sites

## Core Principles

These principles guide all recommendations in this skill:

### 1. TypeScript First
**Always prefer TypeScript** for type safety, better IDE support, and self-documenting code. Type your props, state, and API responses.

```typescript
// ✅ Good: Fully typed component
interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

function UserProfile({ userId, onUpdate }: UserProfileProps) {
  // Implementation
}
```

### 2. Component Composition Over Inheritance
**Prefer composition** to build complex UIs from simple, reusable components.

```typescript
// ✅ Good: Composition
<Card>
  <CardHeader>
    <CardTitle>User Profile</CardTitle>
  </CardHeader>
  <CardContent>
    <UserInfo />
  </CardContent>
</Card>

// ❌ Avoid: Deep inheritance hierarchies
class UserCard extends BaseCard extends AnimatedCard { /* ... */ }
```

### 3. Performance by Default
**Design for performance** from the start. Use code splitting, lazy loading, and memoization appropriately.

```typescript
// ✅ Good: Lazy load heavy components
const HeavyChart = lazy(() => import('./components/HeavyChart'));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  );
}
```

### 4. Accessible by Default
**Build accessible interfaces** from the beginning. Use semantic HTML and proper ARIA attributes.

```typescript
// ✅ Good: Accessible button
<button
  onClick={handleClick}
  aria-label="Close modal"
  aria-pressed={isPressed}
>
  <CloseIcon aria-hidden="true" />
</button>

// ❌ Avoid: Non-semantic div buttons
<div onClick={handleClick}>Close</div>
```

### 5. Test with Confidence
**Write tests that give confidence**, not just coverage. Focus on user behavior, not implementation details.

```typescript
// ✅ Good: Test user behavior
test('user can submit the form with valid data', async () => {
  render(<ContactForm />);

  await userEvent.type(screen.getByLabelText(/name/i), 'John Doe');
  await userEvent.type(screen.getByLabelText(/email/i), 'john@example.com');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  expect(await screen.findByText(/success/i)).toBeInTheDocument();
});
```

## How This Skill Works

### Progressive Resource Loading

This skill is designed to **avoid overwhelming the context window**. Instead of loading all 10 resources at once:

1. **This main SKILL.md** is always loaded (you're reading it now)
2. **Specific resources** are loaded on-demand when you ask about topics
3. **Only relevant content** enters the conversation context

**Example workflow:**

```
You: "How should I optimize this React component's performance?"
↓
I read: ./resources/PERFORMANCE.md
↓
I provide: Specific optimization techniques from that resource
```

### When I Load Resources

I automatically load the appropriate resource when you:

- **Mention specific topics**: "state management", "accessibility", "testing"
- **Ask for best practices**: "What's the best way to style components?"
- **Show code for review**: I analyze and load relevant resources
- **Request architecture guidance**: "How should I structure this feature?"

### Explicit Resource Requests

You can also explicitly request resources:

```
"Show me the React best practices"
"What are the TypeScript patterns for hooks?"
"Load the performance optimization guide"
```

## Common Workflows

### 🎯 Building a New Component

When you say: *"I need to build a user profile component"*

I will:
1. Read `COMPONENT_ARCHITECTURE.md` for structure guidance
2. Read `TYPESCRIPT_PATTERNS.md` for typing patterns
3. Read `ACCESSIBILITY.md` for a11y requirements
4. Provide a complete, typed, accessible component

### 🐛 Debugging Performance Issues

When you say: *"My list is rendering slowly"*

I will:
1. Read `PERFORMANCE.md` for optimization techniques
2. Analyze your code for common issues
3. Suggest specific improvements (memoization, virtualization, etc.)
4. Show before/after examples

### 🎨 Setting Up Styling

When you say: *"Which styling solution should I use?"*

I will:
1. Read `STYLING_APPROACHES.md` for options
2. Consider your project requirements
3. Recommend the best fit with rationale
4. Provide setup instructions

### 🧪 Writing Tests

When you say: *"How do I test this component?"*

I will:
1. Read `TESTING.md` for testing patterns
2. Analyze your component structure
3. Write comprehensive tests following best practices
4. Include edge cases and accessibility checks

## Anti-Patterns to Avoid

Throughout this skill, you'll find guidance on what **not** to do. Here are some universal anti-patterns:

### ❌ 1. Prop Drilling
**Problem**: Passing props through many layers

```typescript
// ❌ Avoid
<App>
  <Header user={user} theme={theme} />
    <Navigation user={user} theme={theme} />
      <NavItem user={user} theme={theme} />
</App>

// ✅ Use Context or state management
const ThemeContext = createContext<Theme>(defaultTheme);
```

### ❌ 2. Premature Optimization
**Problem**: Optimizing before measuring

```typescript
// ❌ Avoid: Memoizing everything
const MyComponent = memo(() => {
  const value = useMemo(() => x + y, [x, y]); // Unnecessary for simple calculation
  const handler = useCallback(() => { /* ... */ }, []); // Unnecessary if not passed down
  // ...
});

// ✅ Optimize when you measure a problem
// Profile first, then optimize hot paths
```

### ❌ 3. Using Index as Key
**Problem**: Causes issues with reordering

```typescript
// ❌ Avoid
{items.map((item, index) => <Item key={index} {...item} />)}

// ✅ Use stable identifiers
{items.map((item) => <Item key={item.id} {...item} />)}
```

### ❌ 4. Direct State Mutation
**Problem**: Breaks React's change detection

```typescript
// ❌ Avoid
const handleUpdate = () => {
  user.name = 'New Name'; // Direct mutation
  setUser(user); // Won't trigger re-render
};

// ✅ Create new objects
const handleUpdate = () => {
  setUser({ ...user, name: 'New Name' });
};
```

### ❌ 5. Missing Dependencies in useEffect
**Problem**: Stale closures and bugs

```typescript
// ❌ Avoid
useEffect(() => {
  doSomethingWith(props.value);
}, []); // Missing dependency!

// ✅ Include all dependencies
useEffect(() => {
  doSomethingWith(props.value);
}, [props.value]);
```

## Integration with Other Skills

This skill works well alongside:

- **`changelog-generator`**: Document feature additions
- **`api-docs-generator`**: Document component APIs
- **Security guidance**: For XSS prevention, secure patterns
- **Code review tools**: For architectural feedback

## Version Requirements

This skill assumes modern tooling:

- **React**: 18+ (for concurrent features)
- **TypeScript**: 5+ (for latest type features)
- **Node.js**: 18+ (for tooling support)
- **Modern bundlers**: Vite 4+, Webpack 5+, or equivalent

For legacy codebases, I'll adapt recommendations appropriately.

## Getting Started

To get the most out of this skill:

1. **Be specific** about your needs: "performance", "accessibility", "testing"
2. **Share your code** for contextual advice
3. **Ask follow-up questions** to dive deeper into topics
4. **Request examples** when concepts are unclear

**Example prompts:**

- "Show me how to optimize this component for performance"
- "What's the best way to manage form state in React?"
- "How do I make this component accessible?"
- "Help me set up testing for this feature"
- "Which state management solution fits my use case?"

## Resource Overview

Each resource file is self-contained and comprehensive:

- **~200-400 lines** per resource
- **Code examples** for every concept
- **Do's and Don'ts** clearly marked
- **Real-world scenarios** included
- **Tool recommendations** with rationale

When you need deep knowledge on a topic, I'll load the full resource and provide detailed, actionable guidance.

---

**Ready to build better frontend applications?** Ask me anything about React, TypeScript, performance, accessibility, or any other frontend topic!
