# Frontend-Focused Plugin Enhancement Plan

## 🎯 Project Context

**Target Audience**: Frontend developers (primary focus)
**Tech Stack**: React.js, TypeScript, modern frontend frameworks
**Secondary**: Occasional full-stack React projects
**Goal**: Integrate best practices from claude-code-infrastructure-showcase while maintaining high quality and avoiding over-engineering

---

## 📋 Four-Phase Integration Plan

### Phase 1: Frontend Development Skills with Layered Architecture 🎨
**Priority**: ⭐⭐⭐⭐⭐ (Highest Value)

#### Objective
Create a comprehensive, modular skill for modern frontend development that doesn't overwhelm the context window.

#### Design Structure
```
plugins/frontend-dev-guidelines/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── frontend-dev/
│       ├── SKILL.md                          # Main entry (<500 lines)
│       └── resources/
│           ├── REACT_BEST_PRACTICES.md       # React 18+ patterns
│           ├── COMPONENT_ARCHITECTURE.md     # Component design
│           ├── STATE_MANAGEMENT.md           # Redux, Context, Zustand
│           ├── TYPESCRIPT_PATTERNS.md        # TS for React
│           ├── STYLING_APPROACHES.md         # CSS-in-JS, Tailwind, MUI
│           ├── PERFORMANCE.md                # Optimization techniques
│           ├── ACCESSIBILITY.md              # a11y best practices
│           ├── TESTING.md                    # Jest, RTL, Playwright
│           ├── BUILD_OPTIMIZATION.md         # Webpack, Vite, bundle analysis
│           └── MODERN_FRAMEWORKS.md          # Next.js, Remix patterns
└── README.md
```

#### Main SKILL.md Structure
```markdown
---
name: frontend-dev
description: Comprehensive React/TypeScript frontend development guidelines. Use when building React components, designing frontend architecture, optimizing performance, or implementing modern frontend patterns.
---

# Frontend Development Guidelines

## Overview
This skill provides comprehensive guidance for modern frontend development with React, TypeScript, and ecosystem tools.

## Quick Reference
- **React Patterns** → See `./resources/REACT_BEST_PRACTICES.md`
- **Component Design** → See `./resources/COMPONENT_ARCHITECTURE.md`
- **State Management** → See `./resources/STATE_MANAGEMENT.md`
- **TypeScript** → See `./resources/TYPESCRIPT_PATTERNS.md`
- **Styling** → See `./resources/STYLING_APPROACHES.md`
- **Performance** → See `./resources/PERFORMANCE.md`
- **Accessibility** → See `./resources/ACCESSIBILITY.md`
- **Testing** → See `./resources/TESTING.md`
- **Build** → See `./resources/BUILD_OPTIMIZATION.md`
- **Frameworks** → See `./resources/MODERN_FRAMEWORKS.md`

## Core Principles
1. **TypeScript First**: Leverage type safety
2. **Component Composition**: Prefer composition over inheritance
3. **Performance by Default**: Code-split, lazy load, memoize
4. **Accessible by Default**: WCAG 2.1 AA compliance
5. **Test with Confidence**: Unit + Integration + E2E

## Usage Pattern
When user mentions specific topics, read the corresponding resource file for detailed guidance.

Example:
- User asks about "performance optimization" → Read `./resources/PERFORMANCE.md`
- User asks about "state management" → Read `./resources/STATE_MANAGEMENT.md`
```

#### Resource File Template (Example: REACT_BEST_PRACTICES.md)
```markdown
# React Best Practices

## Modern React Patterns (React 18+)

### 1. Function Components with Hooks
✅ **Recommended**:
```typescript
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

❌ **Avoid**: Class components (unless maintaining legacy code)

### 2. Custom Hooks for Reusable Logic
... (detailed patterns)

### 3. Concurrent Features
- useTransition for non-urgent updates
- useDeferredValue for derived state
- Suspense for data fetching

... (more sections)
```

#### Benefits of This Design
1. ✅ Main SKILL.md remains lightweight (~300 lines)
2. ✅ Detailed content loaded on-demand
3. ✅ Easy to maintain and update individual topics
4. ✅ No context window overflow
5. ✅ Scales to comprehensive coverage

---

### Phase 2: Enhanced Security Guidance for Frontend 🔒
**Priority**: ⭐⭐⭐⭐⭐ (Critical for Production)

#### Objective
Extend existing `security-guidance` plugin with frontend-specific security patterns, integrated with PreToolUse hooks.

#### Enhancement Strategy

**Extend**: `/home/user/claude-code/plugins/security-guidance/`

#### New Security Rules to Add

```python
# Add to security_reminder_hook.py

FRONTEND_SECURITY_PATTERNS = [
    {
        "ruleName": "react_dangerously_set_html",
        "substrings": ["dangerouslySetInnerHTML"],
        "reminder": """⚠️ Security Warning: dangerouslySetInnerHTML can lead to XSS vulnerabilities.

Safe alternatives:
1. Use plain text: <div>{untrustedText}</div>
2. Use a sanitizer: import DOMPurify from 'dompurify';
   <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
3. Avoid if possible

Only use if:
- Content is from trusted source
- Content is properly sanitized
- No other alternative exists"""
    },
    {
        "ruleName": "eval_or_function_constructor",
        "substrings": ["eval(", "new Function("],
        "reminder": """⚠️ Security Warning: eval() and Function constructor enable code injection.

Safer alternatives:
- For JSON: Use JSON.parse()
- For dynamic imports: Use dynamic import()
- For computed properties: Use object[key] access

Only use if absolutely necessary and input is trusted."""
    },
    {
        "ruleName": "unsafe_href",
        "substrings": ["href={", "href=\"{"],
        "reminder": """⚠️ Security Warning: Dynamic href values can create XSS vulnerabilities.

Dangerous patterns:
- href={userInput}
- href={`javascript:${code}`}

Safe patterns:
- Validate URLs against whitelist
- Use rel="noopener noreferrer" for external links
- Sanitize user input

Example:
```typescript
const isValidUrl = (url: string) => {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
};
```"""
    },
    {
        "ruleName": "unsafe_target_blank",
        "substrings": ["target=\"_blank\"", "target='_blank'"],
        "reminder": """⚠️ Security Best Practice: Always use rel="noopener noreferrer" with target="_blank".

Why: Prevents tabnapping attacks and performance issues.

Safe pattern:
<a href="..." target="_blank" rel="noopener noreferrer">Link</a>"""
    },
    {
        "ruleName": "localstorage_sensitive_data",
        "substrings": ["localStorage.setItem", "sessionStorage.setItem"],
        "reminder": """⚠️ Security Warning: Don't store sensitive data in localStorage/sessionStorage.

Vulnerable to:
- XSS attacks
- Browser extensions
- Local file access

Never store:
- Authentication tokens (use httpOnly cookies)
- Passwords
- API keys
- Personal identifiable information (PII)

Safe to store:
- User preferences
- UI state
- Non-sensitive cache data"""
    },
    {
        "ruleName": "react_refs_dom_manipulation",
        "substrings": [".innerHTML =", ".outerHTML ="],
        "contentPatterns": ["useRef", "createRef"],
        "reminder": """⚠️ Security Warning: Direct DOM manipulation via refs can introduce XSS.

Avoid:
```typescript
ref.current.innerHTML = userContent; // XSS risk
```

Prefer:
```typescript
ref.current.textContent = userContent; // Safe
```

Or use React's rendering:
```typescript
<div>{userContent}</div>
```"""
    },
    {
        "ruleName": "postmessage_origin",
        "substrings": ["postMessage("],
        "reminder": """⚠️ Security Warning: Always validate origin when using postMessage.

Unsafe:
```typescript
window.postMessage(data, '*'); // Any origin can receive
window.addEventListener('message', (e) => {
  processData(e.data); // No origin check
});
```

Safe:
```typescript
window.postMessage(data, 'https://trusted-origin.com');
window.addEventListener('message', (e) => {
  if (e.origin !== 'https://trusted-origin.com') return;
  processData(e.data);
});
```"""
    },
    {
        "ruleName": "react_key_index",
        "substrings": ["key={i}", "key={index}"],
        "reminder": """⚠️ Best Practice Warning: Using array index as key can cause issues.

Problems:
- Performance degradation
- State bugs with reordering
- Incorrect component updates

Use stable identifiers:
```typescript
// Bad
{items.map((item, i) => <Item key={i} {...item} />)}

// Good
{items.map((item) => <Item key={item.id} {...item} />)}
```"""
    },
    {
        "ruleName": "cors_credentials",
        "substrings": ["credentials: 'include'", "withCredentials: true"],
        "reminder": """⚠️ Security Warning: Using credentials with CORS requires careful configuration.

Security checklist:
1. Server must NOT use Access-Control-Allow-Origin: *
2. Server must specify exact origin
3. Use HTTPS in production
4. Validate requests on server side
5. Implement CSRF protection

Example:
```typescript
fetch('/api/data', {
  credentials: 'include', // Sends cookies
  headers: {
    'X-CSRF-Token': getCsrfToken(), // CSRF protection
  }
});
```"""
    },
]
```

#### Integration with Existing Plugin
1. Merge new rules with existing `SECURITY_PATTERNS`
2. Add file type detection for `.tsx`, `.jsx` files
3. Keep session-scoped warning tracking
4. Maintain non-blocking approach (exit code 2 for blocking)

#### Testing Strategy
```bash
# Create test files to verify each rule triggers correctly
plugins/security-guidance/tests/
├── test_react_security.tsx
├── test_dom_manipulation.jsx
└── test_cors_patterns.ts
```

---

### Phase 3: Plugin Developer Toolkit (Meta-Plugin) 🛠️
**Priority**: ⭐⭐⭐⭐ (High Value for Extensibility)

#### Objective
Create a meta-plugin that teaches and assists in building new plugins, following the self-demonstrating pattern from showcase.

#### Structure
```
plugins/plugin-developer-toolkit/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── plugin-developer/
│       ├── SKILL.md                      # Entry point
│       └── resources/
│           ├── BASICS.md                 # Plugin fundamentals
│           ├── SKILLS_GUIDE.md           # Creating skills
│           ├── AGENTS_GUIDE.md           # Creating agents
│           ├── COMMANDS_GUIDE.md         # Creating commands
│           ├── HOOKS_GUIDE.md            # Using hooks
│           ├── BEST_PRACTICES.md         # Quality guidelines
│           └── TEMPLATES.md              # Code templates
├── templates/
│   ├── plugin-basic/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── README.md
│   ├── plugin-with-skill/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── skills/
│   │   │   └── example-skill/
│   │   │       └── SKILL.md
│   │   └── README.md
│   ├── plugin-with-hooks/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── hooks/
│   │   │   ├── hooks.json
│   │   │   └── example-hook.sh
│   │   └── README.md
│   └── plugin-complete/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       ├── agents/
│       ├── commands/
│       ├── hooks/
│       └── README.md
└── README.md
```

#### Main SKILL.md Content
```markdown
---
name: plugin-developer
description: Guide for creating Claude Code plugins, skills, agents, commands, and hooks. Use when user wants to create, extend, or understand plugin development.
---

# Plugin Developer Toolkit

## I am a Meta-Skill
I help you create plugins and skills. My own structure demonstrates best practices:
- This SKILL.md is my entry point
- Resources are organized in `./resources/`
- Templates are ready to use in `./templates/`

## Quick Start Guide

### Creating Your First Plugin
1. Choose a template from `./templates/`
2. Copy to your plugins directory
3. Customize metadata in plugin.json
4. Add your functionality

### Learning Resources
- **Plugin Basics** → `./resources/BASICS.md`
- **Creating Skills** → `./resources/SKILLS_GUIDE.md`
- **Creating Agents** → `./resources/AGENTS_GUIDE.md`
- **Slash Commands** → `./resources/COMMANDS_GUIDE.md`
- **Using Hooks** → `./resources/HOOKS_GUIDE.md`
- **Best Practices** → `./resources/BEST_PRACTICES.md`
- **Templates** → `./resources/TEMPLATES.md`

## Interactive Mode

When you ask me to create a plugin, I will:
1. Ask about your plugin's purpose
2. Suggest appropriate structure (skill/agent/command)
3. Generate boilerplate from templates
4. Add your custom logic
5. Create comprehensive README
6. Ensure it follows best practices

## Examples

**Create a simple skill:**
"Create a plugin with a skill for generating React component boilerplate"

**Create a plugin with hooks:**
"Create a plugin that validates commit messages before committing"

**Create a complex plugin:**
"Create a plugin with agents for code review focusing on accessibility"
```

#### Key Features
1. **Self-Demonstrating**: The plugin itself shows how to structure plugins
2. **Interactive**: Guides users through creation process
3. **Templates**: Copy-paste ready boilerplate
4. **Quality Focused**: Enforces best practices from official docs

---

### Phase 4: PreCompact Hook for Context Preservation 💾
**Priority**: ⭐⭐⭐ (Useful for Long Sessions)

#### Objective
Automatically preserve important development context before Claude compacts the conversation history.

#### Use Cases for Frontend Development
1. **Architecture Decisions**: "Why did we choose Zustand over Redux?"
2. **Component Design Rationale**: "Why did we split this component?"
3. **Performance Optimizations**: "What metrics improved after optimization?"
4. **API Integration Notes**: "How does authentication flow work?"
5. **Bug Investigation**: "What was the root cause of that rendering issue?"

#### Implementation Strategy

**Create New Plugin**: `plugins/context-preservation/`

```
plugins/context-preservation/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── hooks.json
│   ├── pre-compact-handler.sh
│   └── pre-compact-handler.ts
└── README.md
```

#### hooks/hooks.json
```json
{
  "description": "Automatically preserves development context before context compaction",
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact-handler.sh"
      }
    ]
  }
}
```

#### pre-compact-handler.ts Logic
```typescript
interface ContextEntry {
  timestamp: string;
  type: 'decision' | 'architecture' | 'debug' | 'optimization' | 'other';
  content: string;
}

// Read conversation history from stdin
// Identify important patterns:
// - "decided to use X because..."
// - "refactored to improve..."
// - "this bug was caused by..."
// - "optimized by doing..."

// Save to: .claude/session-context/YYYY-MM-DD-HH-MM.json

// Output: "Preserved N important context items"
```

#### What to Preserve
```typescript
const IMPORTANT_PATTERNS = [
  // Decisions
  /decided? to (use|choose|implement|adopt)/i,
  /went with .* because/i,

  // Architecture
  /designed? .* to (be|have|support)/i,
  /structured .* as/i,

  // Problems and Solutions
  /(fixed|solved|resolved) .* by/i,
  /(bug|issue) was caused by/i,

  // Optimizations
  /optimized? .* by/i,
  /improved? .* from .* to/i,

  // Tradeoffs
  /tradeoff between .* and/i,
  /chose .* over .* because/i,
];
```

#### Storage Format
```json
{
  "sessionId": "...",
  "startTime": "2024-01-15T10:30:00Z",
  "compactTime": "2024-01-15T12:45:00Z",
  "project": "/path/to/project",
  "contexts": [
    {
      "timestamp": "2024-01-15T11:20:00Z",
      "type": "decision",
      "content": "Decided to use Zustand instead of Redux because the app state is simple and we want to avoid boilerplate. Zustand provides hooks-based API and TypeScript support out of the box."
    },
    {
      "timestamp": "2024-01-15T12:10:00Z",
      "type": "optimization",
      "content": "Optimized UserList component by adding React.memo and useMemo for filtering. Reduced re-renders from 50/sec to 5/sec during typing."
    }
  ]
}
```

#### Retrieval Mechanism
- Automatically reference in SessionStart hook
- Show summary: "Found 3 preserved context items from previous session"
- Provide command: "Show preserved context" to view details

---

## 🎯 Implementation Sequence

### Week 1: Foundation
1. ✅ Create `frontend-dev-guidelines` plugin structure
2. ✅ Write main SKILL.md and 3 core resources (React, TypeScript, Performance)
3. ✅ Test skill activation with various prompts

### Week 2: Security Enhancement
1. ✅ Extend `security-guidance` with frontend rules
2. ✅ Test all new security patterns
3. ✅ Create test cases for validation

### Week 3: Developer Experience
1. ✅ Build `plugin-developer-toolkit`
2. ✅ Create all templates
3. ✅ Write comprehensive guides in resources/

### Week 4: Context Preservation
1. ✅ Implement `context-preservation` plugin
2. ✅ Test PreCompact hook
3. ✅ Integrate with SessionStart

### Week 5: Integration & Documentation
1. ✅ Test all plugins together
2. ✅ Write user documentation
3. ✅ Create migration guide (if needed)
4. ✅ Update main README

---

## ✅ Quality Checklist

### Official Best Practices Compliance
- [ ] All plugins follow official plugin structure
- [ ] Skills use proper YAML frontmatter
- [ ] Descriptions are clear and trigger-friendly
- [ ] Use `${CLAUDE_PLUGIN_ROOT}` for all paths
- [ ] plugin.json includes all required fields

### Avoid Over-Engineering
- [ ] No custom "auto-activation engine" (trust official mechanism)
- [ ] No complex rule engines (skill descriptions handle triggering)
- [ ] No unnecessary middleware or abstractions
- [ ] Hooks only where truly needed (PreToolUse, PreCompact)

### Code Quality
- [ ] TypeScript strict mode enabled
- [ ] Proper error handling
- [ ] Graceful degradation (failed hooks don't break workflow)
- [ ] Clear logging for debugging

### Documentation
- [ ] Each plugin has comprehensive README
- [ ] Usage examples provided
- [ ] Troubleshooting sections
- [ ] Clear installation instructions

### Frontend Focus
- [ ] React/TypeScript patterns prioritized
- [ ] Modern framework considerations (Next.js, Vite)
- [ ] Security rules relevant to frontend
- [ ] Performance optimization guidance
- [ ] Accessibility included

---

## 🚀 Success Metrics

1. **Skills activate naturally** without explicit invocation
2. **Security warnings** catch real vulnerabilities during development
3. **Context preserved** across long sessions
4. **Easy to extend** - new plugins created using toolkit
5. **No performance degradation** - hooks execute quickly
6. **High adoption** - actually used, not ignored

---

## 📚 Reference Materials

### Official Documentation
- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Agent Skills Overview](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
- [Hooks Reference](https://docs.claude.com/en/docs/claude-code/hooks)

### Showcase Project Learnings
- Layered skill design prevents context overflow
- PreToolUse enables proactive guidance
- PreCompact preserves session knowledge
- Meta-patterns accelerate development

### Anti-Patterns to Avoid
- ❌ Complex auto-activation engines (official mechanism works)
- ❌ skill-rules.json with regex (descriptions are sufficient)
- ❌ Overly granular skills (balance specificity with overhead)
- ❌ Blocking hooks for non-critical guidance
- ❌ Storing sensitive data in context preservation

---

## 🔄 Iterative Improvement

After initial implementation:
1. **Gather feedback** from actual usage
2. **Measure activation accuracy** - are skills triggering appropriately?
3. **Refine descriptions** based on missed activations
4. **Expand resources** as new patterns emerge
5. **Update security rules** with new vulnerabilities

---

## 📝 Next Steps

1. Review and approve this plan
2. Start with Phase 1 (Frontend Dev Guidelines)
3. Iterate based on feedback
4. Gradually roll out subsequent phases

**Estimated Total Time**: 4-5 weeks for full implementation
**Minimum Viable Product**: Phase 1 + Phase 2 (2 weeks)
