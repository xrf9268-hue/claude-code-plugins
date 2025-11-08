# Context Preservation Plugin

Automatically preserves important development context before Claude compacts conversation history. Never lose critical architecture decisions, debugging insights, or design rationales in long coding sessions.

## The Problem

During long Claude Code sessions, the conversation history grows large. When Claude compacts this history to manage context window limits, important information can be lost:

- 🏗️ **Architecture decisions**: "Why did we choose Zustand over Redux?"
- 🐛 **Debugging insights**: "What was the root cause of that rendering issue?"
- ⚡ **Performance optimizations**: "How much did we improve bundle size?"
- 🎯 **Design rationales**: "Why did we structure components this way?"
- ⚖️ **Tradeoff discussions**: "What are the pros and cons of this approach?"

## The Solution

This plugin uses a **PreCompact hook** to automatically extract and save important context before compaction occurs. The preserved information remains accessible across sessions.

## How It Works

### 1. Automatic Detection

The plugin scans conversation history for important patterns:

```javascript
// Architecture decisions
"Decided to use Zustand because..."
"Designed the state management to support..."
"Chose TypeScript strict mode for better type safety"

// Performance optimizations
"Optimized rendering by memoizing expensive calculations"
"Reduced bundle size from 500KB to 200KB by..."
"Improved LCP from 3.5s to 1.8s by lazy loading"

// Bug fixes and debugging
"Bug was caused by stale closure in useEffect"
"Fixed memory leak by cleaning up subscriptions"
"Root cause was missing dependency in useMemo"

// Design tradeoffs
"Tradeoff between bundle size and developer experience"
"Pros: simpler code, Cons: slightly slower"
```

### 2. Context Extraction

For each important pattern, the plugin:
- Extracts the relevant text with surrounding context
- Categorizes by type (architecture, optimization, debugging, etc.)
- Includes timestamp and conversation position
- Deduplicates similar content

### 3. Persistent Storage

Preserved context is saved to:

```
.claude/session-context/
├── {session-id}_{timestamp}.json    # Individual session contexts
└── summary.json                      # Summary of all sessions
```

### 4. Session Restoration

On SessionStart, the plugin:
- Checks for preserved contexts
- Notifies you if previous contexts exist
- Allows you to review preserved information

## Installation

```bash
cp -r plugins/context-preservation ~/.claude/plugins/
chmod +x ~/.claude/plugins/context-preservation/hooks/*.sh
```

**Requirements**:
- Node.js (for the PreCompact handler)
- jq (for SessionStart summary, optional)

## Usage

### Automatic Mode

The plugin works automatically:

1. **During Session**: Have normal conversations with Claude
2. **Before Compaction**: Plugin automatically preserves important context
3. **After Compaction**: Context safely stored in `.claude/session-context/`
4. **Next Session**: Get notified of preserved contexts

### Viewing Preserved Context

```
You: "Show me the preserved context"

Or

You: "What architecture decisions were made in the last session?"
```

Claude can read the preserved context files and summarize them for you.

### Manual Context Queries

```bash
# View summary
cat .claude/session-context/summary.json

# View specific session context
cat .claude/session-context/{session-id}_{timestamp}.json

# Search for specific topics
grep -r "architecture" .claude/session-context/
```

## Preserved Context Structure

Each preserved context file contains:

```json
{
  "sessionId": "abc123",
  "preservedAt": "2024-01-15T14:30:00Z",
  "project": "/path/to/project",
  "contextCount": 12,
  "contexts": [
    {
      "type": "architecture",
      "content": "Decided to use Zustand instead of Redux because the app state is simple and we want to avoid boilerplate. Zustand provides hooks-based API and TypeScript support out of the box.",
      "role": "assistant",
      "timestamp": "2024-01-15T13:20:00Z"
    },
    {
      "type": "optimization",
      "content": "Optimized UserList component by adding React.memo and useMemo for filtering. Reduced re-renders from 50/sec to 5/sec during typing.",
      "role": "assistant",
      "timestamp": "2024-01-15T14:10:00Z"
    }
  ]
}
```

## Context Types

The plugin categorizes context into:

### 1. Architecture
- System design decisions
- Technology choices
- Structural patterns
- Component architecture

**Example**: "Designed the API layer with a repository pattern to abstract data fetching"

### 2. Tradeoffs
- Pros and cons discussions
- Alternative approaches considered
- Decision rationales

**Example**: "Tradeoff between bundle size and developer experience - chose DX"

### 3. Optimization
- Performance improvements
- Bundle size reductions
- Rendering optimizations
- Memory improvements

**Example**: "Improved initial load time from 3.2s to 1.4s by code-splitting routes"

### 4. Debugging
- Bug root causes
- Fix explanations
- Debugging insights

**Example**: "Bug was caused by incorrect dependency array in useEffect - added missing prop"

### 5. Implementation
- Implementation approaches
- Solution strategies
- Technical details

**Example**: "Implemented authentication using JWT tokens with refresh token rotation"

### 6. Requirements
- Project requirements
- Constraints
- Must-haves and limitations

**Example**: "Must support IE11, which constrains us to ES5 transpilation"

## Configuration

### Disable Context Preservation

Set environment variable:

```bash
export DISABLE_CONTEXT_PRESERVATION=1
```

### Adjust Storage Location

Edit `hooks/pre-compact-handler.js`:

```javascript
const contextDir = path.join(process.cwd(), '.claude', 'session-context');
// Change to your preferred location
```

### Customize Patterns

Add your own important patterns in `pre-compact-handler.js`:

```javascript
const importantPatterns = [
  // Add custom patterns
  {
    type: 'custom-category',
    patterns: [
      /your pattern here/i,
      /another pattern/i,
    ]
  }
];
```

## Examples

### Example 1: Architecture Decisions

**During session**:
```
You: "Should we use Redux or Zustand for state management?"
Claude: "For this project, I recommend Zustand because:
        1. Your state is relatively simple
        2. You want to avoid Redux boilerplate
        3. TypeScript support is excellent out of the box..."
```

**Preserved context**:
```json
{
  "type": "architecture",
  "content": "Decided to use Zustand over Redux because state is simple and we want to avoid boilerplate. Zustand provides hooks-based API and TypeScript support."
}
```

### Example 2: Performance Optimization

**During session**:
```
You: "This component is rendering too slowly"
Claude: "Optimized by adding React.memo and memoizing the expensive
        filter function. Reduced renders from 50/sec to 5/sec."
```

**Preserved context**:
```json
{
  "type": "optimization",
  "content": "Optimized rendering by adding React.memo and memoizing filter. Reduced renders from 50/sec to 5/sec."
}
```

### Example 3: Bug Root Cause

**During session**:
```
You: "Why was this component showing stale data?"
Claude: "Bug was caused by missing dependency in useEffect. The
        effect wasn't re-running when userId changed..."
```

**Preserved context**:
```json
{
  "type": "debugging",
  "content": "Bug was caused by missing userId dependency in useEffect. Effect wasn't re-running on user changes."
}
```

## Maintenance

### Cleanup Old Contexts

Context files accumulate over time. Clean them up periodically:

```bash
# Remove contexts older than 30 days
find .claude/session-context -name "*.json" -mtime +30 -delete

# Keep only summary
rm .claude/session-context/*.json
# (summary.json is preserved)
```

### Summary File

The `summary.json` tracks all sessions:

```json
{
  "sessions": [
    {
      "sessionId": "abc123",
      "lastPreserved": "2024-01-15T14:30:00Z",
      "contextCount": 12
    }
  ]
}
```

Automatically maintains last 20 sessions.

## Troubleshooting

### No Context Preserved

**Possible causes**:
1. No important patterns detected
2. Conversation too short
3. Hook not executing

**Debug**:
```bash
# Check if PreCompact hook ran
ls -la .claude/session-context/

# Test hook manually
echo '{"session_id":"test","messages":[{"content":"Decided to use React"}]}' | \
  node hooks/pre-compact-handler.js
```

### Node.js Not Found

**Error**: `node: command not found`

**Solution**:
```bash
# Install Node.js
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs

# Verify
node --version
```

### Permission Denied

**Error**: `EACCES: permission denied`

**Solution**:
```bash
chmod +x hooks/*.sh
chmod 755 hooks/
```

## Technical Details

### Pattern Matching

The plugin uses regular expressions to match important patterns:

```javascript
/decided? to (use|choose|implement|adopt)/i
/went with .* because/i
/optimized? .* by/i
/bug.* was caused by/i
```

### Performance

- **Low overhead**: Only runs on PreCompact (infrequent)
- **Fast execution**: Regex matching on message text
- **Graceful failure**: Errors don't block compaction

### Privacy

- **Local storage**: All data stays on your machine
- **No network**: No data sent anywhere
- **Git-ignored**: `.claude/` is typically in `.gitignore`

## Integration with Other Plugins

Works well with:
- **frontend-dev-guidelines**: Preserves frontend architecture decisions
- **security-guidance**: Saves security considerations
- **plugin-developer-toolkit**: Preserves plugin development insights

## Use Cases

### Long Feature Development

```
Session 1: Architecture design
Session 2: Implementation (architecture preserved)
Session 3: Optimization (previous decisions available)
Session 4: Review (full context of decisions)
```

### Team Onboarding

New team member reviews preserved contexts to understand:
- Why certain technologies were chosen
- What tradeoffs were considered
- How optimizations were achieved

### Documentation

Export preserved contexts to create:
- Architecture Decision Records (ADRs)
- Technical design documents
- Performance optimization logs

## Future Enhancements

Potential improvements:
- Export to markdown format
- Integration with note-taking tools
- Automatic ADR generation
- Context search interface
- Visual timeline of decisions

## Contributing

To improve this plugin:
1. Add new important patterns
2. Enhance categorization logic
3. Improve context extraction
4. Add export formats

## Version History

### 1.0.0 (Current)
- ✅ PreCompact hook integration
- ✅ 6 context categories
- ✅ Automatic pattern detection
- ✅ Persistent storage
- ✅ Session summary
- ✅ SessionStart notifications

## License

MIT License - See repository LICENSE for details

## Feedback

Found an important pattern we're missing? Open an issue!

---

**Never lose important context again!** 📚
