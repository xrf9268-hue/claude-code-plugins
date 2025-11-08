# Frontend Development Guidelines Plugin

Comprehensive, modular skill for modern React/TypeScript frontend development. This plugin provides expert guidance on component design, performance optimization, accessibility, testing, and more.

## Overview

This plugin demonstrates **layered skill architecture** - a pattern borrowed from production-tested infrastructure that prevents context window overflow while maintaining comprehensive coverage.

### Key Features

- 🎯 **Modular Resource Structure**: Main skill file stays lightweight (<500 lines), detailed content loaded on-demand
- ⚡ **Performance-Focused**: Covers code splitting, memoization, bundle optimization, and Web Vitals
- ♿ **Accessibility Built-in**: WCAG 2.1 compliant patterns and testing strategies
- 📘 **TypeScript First**: Comprehensive typing patterns for React components and hooks
- 🧪 **Testing Best Practices**: Unit, integration, and E2E testing guidance
- 🎨 **Multiple Styling Approaches**: CSS Modules, Tailwind, Styled-Components, MUI
- 🔄 **State Management**: From local state to Redux Toolkit, Zustand, and React Query

## Plugin Structure

```
frontend-dev-guidelines/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/
│   └── frontend-dev/
│       ├── SKILL.md             # Main entry point (~400 lines)
│       └── resources/           # Detailed guides (loaded on-demand)
│           ├── REACT_BEST_PRACTICES.md
│           ├── TYPESCRIPT_PATTERNS.md
│           ├── PERFORMANCE.md
│           ├── COMPONENT_ARCHITECTURE.md
│           ├── STATE_MANAGEMENT.md
│           ├── STYLING_APPROACHES.md
│           ├── ACCESSIBILITY.md
│           ├── TESTING.md
│           ├── BUILD_OPTIMIZATION.md
│           └── MODERN_FRAMEWORKS.md
└── README.md                    # This file
```

## How It Works

### Automatic Activation

This skill activates automatically when you:

- Build React components
- Ask about TypeScript patterns
- Need performance optimization
- Work on accessibility
- Set up testing
- Configure builds or frameworks

**Example prompts that trigger this skill:**

```
"How should I optimize this React component?"
"What's the best way to type this hook in TypeScript?"
"Help me make this component accessible"
"Which state management solution should I use?"
"How do I test this component?"
```

### Progressive Resource Loading

The plugin uses a **two-tier architecture**:

1. **Main SKILL.md**: Always loaded, provides overview and quick reference
2. **Resources**: Loaded on-demand when specific topics are discussed

**Example workflow:**

```
You: "How do I optimize performance for a list with 10,000 items?"
↓
Claude loads: ./resources/PERFORMANCE.md
↓
Claude provides: Virtual scrolling patterns, bundle optimization, memoization strategies
```

This design ensures:
- ✅ No context window overflow
- ✅ Fast activation (main file is lightweight)
- ✅ Comprehensive coverage (resources are detailed)
- ✅ Relevant content only (load what you need)

## Resource Coverage

### 1. React Best Practices (REACT_BEST_PRACTICES.md)

- Function components and hooks
- Component lifecycle patterns
- Concurrent features (Suspense, transitions)
- Common pitfalls and solutions
- Custom hooks patterns
- Error boundaries

**When loaded**: React component questions, hook usage, lifecycle issues

### 2. TypeScript Patterns (TYPESCRIPT_PATTERNS.md)

- Component typing
- Props patterns (optional, required, union types)
- Hooks typing (useState, useRef, useReducer, useContext)
- Event handlers
- Refs and DOM
- Generic components
- Utility types

**When loaded**: TypeScript questions, type errors, component typing

### 3. Performance Optimization (PERFORMANCE.md)

- Core Web Vitals (LCP, FID/INP, CLS)
- Code splitting strategies
- Memoization (React.memo, useMemo, useCallback)
- Virtual scrolling
- Bundle optimization
- Image optimization
- Performance monitoring

**When loaded**: Performance issues, slow rendering, bundle size questions

### 4. Component Architecture (COMPONENT_ARCHITECTURE.md)

- Composition patterns
- Props design
- Compound components
- Container/Presentation pattern
- Render props (and modern alternatives)

**When loaded**: Component design questions, architecture discussions

### 5. State Management (STATE_MANAGEMENT.md)

- Local state (useState, useReducer)
- Context API
- Redux Toolkit
- Zustand (lightweight alternative)
- React Query / SWR (server state)

**When loaded**: State management questions, data flow issues

### 6. Styling Approaches (STYLING_APPROACHES.md)

- CSS Modules
- Tailwind CSS
- Styled-Components (CSS-in-JS)
- Material-UI (MUI)
- Comparison and recommendations

**When loaded**: Styling questions, CSS-in-JS, design system discussions

### 7. Accessibility (ACCESSIBILITY.md)

- WCAG 2.1 principles
- Semantic HTML
- ARIA attributes
- Keyboard navigation
- Screen reader support
- Testing accessibility

**When loaded**: Accessibility questions, a11y compliance, WCAG requirements

### 8. Testing Strategy (TESTING.md)

- Jest and React Testing Library
- Unit testing patterns
- Integration testing
- E2E with Playwright
- Testing hooks
- Mocking APIs

**When loaded**: Testing questions, test writing, test strategy

### 9. Build Optimization (BUILD_OPTIMIZATION.md)

- Webpack configuration
- Vite setup
- Tree shaking
- Code splitting
- Bundle analysis
- Production checklist

**When loaded**: Build configuration, deployment preparation, optimization

### 10. Modern Frameworks (MODERN_FRAMEWORKS.md)

- Next.js (App Router, Server Components)
- Remix patterns
- Vite project setup
- Framework comparisons

**When loaded**: Framework questions, Next.js, Remix, migration discussions

## Installation

### Option 1: Copy to Project

```bash
cp -r plugins/frontend-dev-guidelines ~/.claude/plugins/
```

### Option 2: Symlink for Development

```bash
ln -s $(pwd)/plugins/frontend-dev-guidelines ~/.claude/plugins/frontend-dev-guidelines
```

### Verify Installation

Run Claude Code and ask a frontend question:

```
You: "What's the best way to optimize a React component?"
```

The skill should activate automatically.

## Usage Examples

### Example 1: Performance Optimization

```
You: "This component re-renders too often. How can I fix it?"

Claude activates frontend-dev skill
→ Loads PERFORMANCE.md resource
→ Analyzes your component
→ Suggests React.memo, useMemo, useCallback with code examples
→ Explains when to use each optimization
```

### Example 2: TypeScript Typing

```
You: "How do I type a generic list component in TypeScript?"

Claude activates frontend-dev skill
→ Loads TYPESCRIPT_PATTERNS.md resource
→ Provides generic component pattern
→ Shows complete typed example
→ Explains utility types for React
```

### Example 3: Accessibility Review

```
You: "Is this modal component accessible?"

Claude activates frontend-dev skill
→ Loads ACCESSIBILITY.md resource
→ Reviews modal for WCAG compliance
→ Identifies missing ARIA attributes
→ Suggests keyboard navigation improvements
→ Provides accessible code example
```

## Best Practices

### When to Use This Skill

✅ **Use for:**
- Building new React components
- Optimizing existing code
- Ensuring accessibility
- Setting up testing
- Architecting features
- Choosing technologies

❌ **Don't use for:**
- Backend development
- Non-React frameworks (Vue, Angular)
- Basic JavaScript questions

### Getting the Most Value

1. **Be specific**: "How do I optimize performance?" → "How do I reduce re-renders in this list component?"
2. **Share code**: Include relevant code snippets for contextual advice
3. **Ask follow-ups**: Resources are comprehensive - dive deeper into topics
4. **Request examples**: All patterns have working code examples

## Design Philosophy

This plugin follows several key principles:

### 1. Progressive Disclosure

Instead of loading all 10 resources (3000+ lines) upfront:
- Main SKILL.md provides overview (~400 lines)
- Resources loaded only when needed
- Prevents context window exhaustion

### 2. Official Pattern Compliance

- Follows official Claude Code plugin specifications
- Uses standard YAML frontmatter
- Relies on Claude's automatic skill activation
- No custom activation logic required

### 3. Production-Tested Patterns

Patterns in this plugin are drawn from:
- Real-world React applications
- Modern best practices (React 18+, TypeScript 5+)
- Performance optimization experience
- Accessibility compliance requirements

### 4. Framework Agnostic (Where Possible)

While focused on React:
- TypeScript patterns apply broadly
- Performance principles are universal
- Accessibility guidelines are standard
- Testing strategies adapt to any framework

## Troubleshooting

### Skill Not Activating

**Check:**
1. Plugin is in the correct directory (`~/.claude/plugins/`)
2. `plugin.json` is valid JSON
3. SKILL.md has valid YAML frontmatter
4. Your prompt includes frontend-related keywords

**Test activation:**
```
You: "Show me React best practices"
```

Should load the skill immediately.

### Resource Not Loading

If a resource isn't loading when expected:
1. Resource file exists in `skills/frontend-dev/resources/`
2. File name matches reference in SKILL.md
3. Try explicit request: "Load the performance optimization guide"

### Context Window Issues

If you still hit context limits:
- Resources are already optimized (~200-400 lines each)
- Only loaded resources enter context
- Consider breaking conversation into focused sessions
- Use separate sessions for different topics

## Contributing

To extend this plugin:

### Adding New Resources

1. Create new resource file:
   ```bash
   touch skills/frontend-dev/resources/NEW_TOPIC.md
   ```

2. Update main SKILL.md:
   ```markdown
   - 🎯 **New Topic** → `./resources/NEW_TOPIC.md`
     - Description of coverage
   ```

3. Follow existing resource format:
   - Table of contents
   - Code examples (✅ Good / ❌ Avoid)
   - Best practices checklist
   - ~200-400 lines

### Updating Existing Resources

Resources are self-contained - update them independently:
- Keep code examples current
- Add new patterns as ecosystem evolves
- Maintain consistent formatting
- Update version requirements

## Version History

### 1.0.0 (Current)

- ✅ Complete modular skill architecture
- ✅ 10 comprehensive resource files
- ✅ React 18+ and TypeScript 5+ patterns
- ✅ Performance, accessibility, testing coverage
- ✅ Modern framework guidance (Next.js, Vite, Remix)

## Related Plugins

This plugin works well with:
- **security-guidance**: Frontend security patterns (XSS, CORS, etc.)
- **doc-generator-with-skills**: Document your components
- **code-review**: Review frontend code for issues
- **commit-commands**: Commit your changes

## Learn More

- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Skills Documentation](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

## License

This plugin is part of the Claude Code project. See repository LICENSE for details.

## Author

Claude Code Team

## Feedback

Found an issue or have a suggestion? Please open an issue in the main repository.

---

**Ready to build better React applications?** This skill is automatically activated when you need it. Just start asking frontend development questions!
