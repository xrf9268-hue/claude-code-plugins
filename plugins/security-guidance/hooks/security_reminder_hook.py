#!/usr/bin/env python3
"""
Security Reminder Hook for Claude Code

This hook checks for security patterns in file edits and warns about potential vulnerabilities.

Exit codes (for PreToolUse hooks):
    0 = Allow operation to proceed (no security issues detected or hook error)
    2 = Block operation (security issue detected, warning sent to Claude)

Note: This hook uses exit code 2 to block file operations when security patterns
are detected. Exit code 0 is used both for safe operations and hook errors
(fail-safe behavior to avoid blocking Claude Code on hook failures).
"""

import json
import os
import random
import sys
from datetime import datetime

# Debug log file
DEBUG_LOG_FILE = "/tmp/security-warnings-log.txt"


def debug_log(message):
    """Append debug message to log file with timestamp."""
    try:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
        with open(DEBUG_LOG_FILE, "a") as f:
            f.write(f"[{timestamp}] {message}\n")
    except Exception as e:
        # Silently ignore logging errors to avoid disrupting the hook
        pass


# State file to track warnings shown (session-scoped using session ID)

# Security patterns configuration
SECURITY_PATTERNS = [
    {
        "ruleName": "github_actions_workflow",
        "path_check": lambda path: ".github/workflows/" in path
        and (path.endswith(".yml") or path.endswith(".yaml")),
        "reminder": """You are editing a GitHub Actions workflow file. Be aware of these security risks:

1. **Command Injection**: Never use untrusted input (like issue titles, PR descriptions, commit messages) directly in run: commands without proper escaping
2. **Use environment variables**: Instead of ${{ github.event.issue.title }}, use env: with proper quoting
3. **Review the guide**: https://github.blog/security/vulnerability-research/how-to-catch-github-actions-workflow-injections-before-attackers-do/

Example of UNSAFE pattern to avoid:
run: echo "${{ github.event.issue.title }}"

Example of SAFE pattern:
env:
  TITLE: ${{ github.event.issue.title }}
run: echo "$TITLE"

Other risky inputs to be careful with:
- github.event.issue.body
- github.event.pull_request.title
- github.event.pull_request.body
- github.event.comment.body
- github.event.review.body
- github.event.review_comment.body
- github.event.pages.*.page_name
- github.event.commits.*.message
- github.event.head_commit.message
- github.event.head_commit.author.email
- github.event.head_commit.author.name
- github.event.commits.*.author.email
- github.event.commits.*.author.name
- github.event.pull_request.head.ref
- github.event.pull_request.head.label
- github.event.pull_request.head.repo.default_branch
- github.head_ref""",
    },
    {
        "ruleName": "child_process_exec",
        "substrings": ["child_process.exec", "exec(", "execSync("],
        "reminder": """⚠️ Security Warning: Using child_process.exec() can lead to command injection vulnerabilities.

This codebase provides a safer alternative: src/utils/execFileNoThrow.ts

Instead of:
  exec(`command ${userInput}`)

Use:
  import { execFileNoThrow } from '../utils/execFileNoThrow.js'
  await execFileNoThrow('command', [userInput])

The execFileNoThrow utility:
- Uses execFile instead of exec (prevents shell injection)
- Handles Windows compatibility automatically
- Provides proper error handling
- Returns structured output with stdout, stderr, and status

Only use exec() if you absolutely need shell features and the input is guaranteed to be safe.""",
    },
    {
        "ruleName": "new_function_injection",
        "substrings": ["new Function"],
        "reminder": "⚠️ Security Warning: Using new Function() with dynamic strings can lead to code injection vulnerabilities. Consider alternative approaches that don't evaluate arbitrary code. Only use new Function() if you truly need to evaluate arbitrary dynamic code.",
    },
    {
        "ruleName": "eval_injection",
        "substrings": ["eval("],
        "reminder": "⚠️ Security Warning: eval() executes arbitrary code and is a major security risk. Consider using JSON.parse() for data parsing or alternative design patterns that don't require code evaluation. Only use eval() if you truly need to evaluate arbitrary code.",
    },
    {
        "ruleName": "react_dangerously_set_html",
        "substrings": ["dangerouslySetInnerHTML"],
        "reminder": "⚠️ Security Warning: dangerouslySetInnerHTML can lead to XSS vulnerabilities if used with untrusted content. Ensure all content is properly sanitized using an HTML sanitizer library like DOMPurify, or use safe alternatives.",
    },
    {
        "ruleName": "document_write_xss",
        "substrings": ["document.write"],
        "reminder": "⚠️ Security Warning: document.write() can be exploited for XSS attacks and has performance issues. Use DOM manipulation methods like createElement() and appendChild() instead.",
    },
    {
        "ruleName": "innerHTML_xss",
        "substrings": [".innerHTML =", ".innerHTML="],
        "reminder": "⚠️ Security Warning: Setting innerHTML with untrusted content can lead to XSS vulnerabilities. Use textContent for plain text or safe DOM methods for HTML content. If you need HTML support, consider using an HTML sanitizer library such as DOMPurify.",
    },
    {
        "ruleName": "pickle_deserialization",
        "substrings": ["pickle"],
        "reminder": "⚠️ Security Warning: Using pickle with untrusted content can lead to arbitrary code execution. Consider using JSON or other safe serialization formats instead. Only use pickle if it is explicitly needed or requested by the user.",
    },
    {
        "ruleName": "os_system_injection",
        "substrings": ["os.system", "from os import system"],
        "reminder": "⚠️ Security Warning: This code appears to use os.system. This should only be used with static arguments and never with arguments that could be user-controlled.",
    },
    # Frontend-specific security patterns
    {
        "ruleName": "unsafe_href",
        "substrings": ["href={", 'href="{'],
        "reminder": """⚠️ Security Warning: Dynamic href values can create XSS vulnerabilities.

Dangerous patterns:
- href={userInput}
- href={`javascript:${code}`}
- href={'javascript:' + userCode}

Safe patterns:
1. Validate URLs against whitelist:
   ```typescript
   const isValidUrl = (url: string) => {
     try {
       const parsed = new URL(url);
       return ['http:', 'https:', 'mailto:', 'tel:'].includes(parsed.protocol);
     } catch {
       return false;
     }
   };

   if (!isValidUrl(userUrl)) {
     throw new Error('Invalid URL');
   }
   ```

2. Use rel="noopener noreferrer" for external links:
   ```typescript
   <a href={externalUrl} target="_blank" rel="noopener noreferrer">
   ```

3. Sanitize user input before using in href attributes.""",
    },
    {
        "ruleName": "unsafe_target_blank",
        "substrings": ['target="_blank"', "target='_blank'"],
        "reminder": """⚠️ Security Best Practice: Always use rel="noopener noreferrer" with target="_blank".

Why this matters:
1. **Tabnapping Prevention**: Without rel="noopener", the new page can access window.opener
2. **Performance**: The new page runs in the same process, impacting performance
3. **Privacy**: Prevents referer leakage in some cases

Safe pattern:
```typescript
<a href={url} target="_blank" rel="noopener noreferrer">
  Link text
</a>
```

Additional considerations:
- For same-origin links, rel="opener" is safe
- For external links, ALWAYS use rel="noopener noreferrer"
- Consider using noreferrer for additional privacy""",
    },
    {
        "ruleName": "localstorage_sensitive_data",
        "substrings": ["localStorage.setItem", "sessionStorage.setItem"],
        "reminder": """⚠️ Security Warning: Don't store sensitive data in localStorage/sessionStorage.

Why it's dangerous:
1. Accessible to all JavaScript (including third-party scripts)
2. Vulnerable to XSS attacks
3. Persists across sessions (localStorage)
4. No built-in encryption
5. Can be accessed by browser extensions

Never store:
- ❌ Authentication tokens (use httpOnly cookies instead)
- ❌ API keys or secrets
- ❌ Passwords or password hashes
- ❌ Personal identifiable information (PII)
- ❌ Credit card information
- ❌ Social security numbers

Safe to store:
- ✅ User preferences (theme, language)
- ✅ UI state (sidebar collapsed, tab selection)
- ✅ Non-sensitive cache data
- ✅ Analytics IDs (public data)

For authentication tokens:
```typescript
// ❌ Bad: Store in localStorage
localStorage.setItem('authToken', token);

// ✅ Good: Use httpOnly cookies set by backend
// Server sets: Set-Cookie: authToken=xxx; HttpOnly; Secure; SameSite=Strict
```""",
    },
    {
        "ruleName": "react_refs_dom_manipulation",
        "substrings": [".innerHTML =", ".outerHTML =", "ref.current"],
        "reminder": """⚠️ Security Warning: Direct DOM manipulation via refs can introduce XSS vulnerabilities.

Dangerous pattern:
```typescript
const ref = useRef<HTMLDivElement>(null);
ref.current.innerHTML = userContent; // XSS risk!
```

Safe alternatives:
1. Use textContent for plain text:
   ```typescript
   ref.current.textContent = userContent; // Safe
   ```

2. Use React's rendering (preferred):
   ```typescript
   function Component({ content }: { content: string }) {
     return <div>{content}</div>; // React auto-escapes
   }
   ```

3. If you need HTML, sanitize first:
   ```typescript
   import DOMPurify from 'dompurify';

   const sanitized = DOMPurify.sanitize(userHTML);
   ref.current.innerHTML = sanitized;
   ```

Best practice: Avoid direct DOM manipulation in React. Let React manage the DOM.""",
    },
    {
        "ruleName": "postmessage_origin",
        "substrings": ["postMessage(", "addEventListener('message'", 'addEventListener("message"'],
        "reminder": """⚠️ Security Warning: Always validate origin when using postMessage API.

Unsafe patterns:
```typescript
// ❌ Bad: Accept messages from any origin
window.postMessage(data, '*');

window.addEventListener('message', (event) => {
  processData(event.data); // No origin check!
});
```

Safe patterns:
```typescript
// ✅ Good: Specify exact origin
window.postMessage(data, 'https://trusted-origin.com');

// ✅ Good: Validate sender origin
window.addEventListener('message', (event) => {
  // Whitelist of trusted origins
  const trustedOrigins = ['https://app.example.com', 'https://api.example.com'];

  if (!trustedOrigins.includes(event.origin)) {
    console.warn('Untrusted origin:', event.origin);
    return; // Ignore message
  }

  // Validate data structure
  if (typeof event.data !== 'object' || !event.data.type) {
    return;
  }

  processData(event.data);
});
```

Additional security:
- Validate data structure before processing
- Never execute code from postMessage data
- Use structured cloning for data transfer
- Consider using a message protocol/schema""",
    },
    {
        "ruleName": "react_key_index",
        "substrings": ["key={i}", "key={index}", "key={idx}"],
        "reminder": """⚠️ Best Practice Warning: Using array index as React key can cause issues.

Problems with index keys:
1. **State bugs**: Component state persists incorrectly when list reorders
2. **Performance**: React can't optimize reconciliation
3. **Incorrect updates**: Wrong components receive wrong props
4. **Animation issues**: Transitions apply to wrong elements

Example of the problem:
```typescript
// ❌ Bad: Using index
{items.map((item, index) => (
  <TodoItem key={index} {...item} />
))}

// If items reorder, React thinks item at index 0 is the same component
// but with different props, causing state and animation issues
```

Correct approach:
```typescript
// ✅ Good: Using stable, unique identifier
{items.map((item) => (
  <TodoItem key={item.id} {...item} />
))}
```

When index is acceptable:
- ✅ List never reorders
- ✅ List is static (no add/remove)
- ✅ Items have no internal state
- ✅ No animations or transitions

Best practice: Always use stable, unique identifiers as keys.""",
    },
    {
        "ruleName": "cors_credentials",
        "substrings": ["credentials: 'include'", "withCredentials: true"],
        "reminder": """⚠️ Security Warning: Using credentials with CORS requires careful configuration.

When you use credentials: 'include' or withCredentials: true:

Security requirements:
1. ❌ Server CANNOT use Access-Control-Allow-Origin: *
2. ✅ Server MUST specify exact origin
3. ✅ Use HTTPS in production (not HTTP)
4. ✅ Implement CSRF protection
5. ✅ Validate requests on server side

Example:
```typescript
// Frontend
fetch('/api/data', {
  credentials: 'include', // Sends cookies
  headers: {
    'X-CSRF-Token': getCsrfToken(), // CSRF protection required!
  }
});

// Backend must respond with:
// Access-Control-Allow-Origin: https://your-exact-domain.com (NOT *)
// Access-Control-Allow-Credentials: true
// Vary: Origin
```

Common vulnerabilities:
- ❌ Using wildcard origin with credentials (blocked by browsers)
- ❌ Missing CSRF protection
- ❌ Accepting any origin dynamically without validation
- ❌ Using HTTP instead of HTTPS

CSRF protection strategies:
1. Double-submit cookie pattern
2. Synchronizer token pattern
3. SameSite cookie attribute (Strict or Lax)
4. Custom request headers

Safe alternative:
If you don't need cookies, use Authorization header:
```typescript
fetch('/api/data', {
  headers: {
    'Authorization': `Bearer ${token}`,
  }
});
```""",
    },
    {
        "ruleName": "window_name_xss",
        "substrings": ["window.name", "window['name']"],
        "reminder": """⚠️ Security Warning: window.name can be a source of XSS vulnerabilities.

Why it's dangerous:
- window.name persists across page navigations
- Can be set by any page (even cross-origin)
- Often overlooked as untrusted input

Unsafe pattern:
```typescript
// ❌ Bad: Direct use of window.name
document.getElementById('display').innerHTML = window.name;
eval(window.name); // Very dangerous!
```

Safe pattern:
```typescript
// ✅ Good: Treat as untrusted input
const name = window.name;
if (typeof name === 'string' && name.length < 100) {
  // Validate and sanitize
  const sanitized = DOMPurify.sanitize(name);
  element.textContent = sanitized; // Use textContent, not innerHTML
}
```

Best practices:
1. Always validate window.name content
2. Never execute code from window.name
3. Never insert into DOM without sanitization
4. Prefer other storage mechanisms (sessionStorage, state)""",
    },
]


def get_state_file(session_id):
    """Get session-specific state file path."""
    return os.path.expanduser(f"~/.claude/security_warnings_state_{session_id}.json")


def cleanup_old_state_files():
    """Remove state files older than 30 days."""
    try:
        state_dir = os.path.expanduser("~/.claude")
        if not os.path.exists(state_dir):
            return

        current_time = datetime.now().timestamp()
        thirty_days_ago = current_time - (30 * 24 * 60 * 60)

        for filename in os.listdir(state_dir):
            if filename.startswith("security_warnings_state_") and filename.endswith(
                ".json"
            ):
                file_path = os.path.join(state_dir, filename)
                try:
                    file_mtime = os.path.getmtime(file_path)
                    if file_mtime < thirty_days_ago:
                        os.remove(file_path)
                except (OSError, IOError):
                    pass  # Ignore errors for individual file cleanup
    except Exception:
        pass  # Silently ignore cleanup errors


def load_state(session_id):
    """Load the state of shown warnings from file."""
    state_file = get_state_file(session_id)
    if os.path.exists(state_file):
        try:
            with open(state_file, "r") as f:
                return set(json.load(f))
        except (json.JSONDecodeError, IOError):
            return set()
    return set()


def save_state(session_id, shown_warnings):
    """Save the state of shown warnings to file."""
    state_file = get_state_file(session_id)
    try:
        os.makedirs(os.path.dirname(state_file), exist_ok=True)
        with open(state_file, "w") as f:
            json.dump(list(shown_warnings), f)
    except IOError as e:
        debug_log(f"Failed to save state file: {e}")
        pass  # Fail silently if we can't save state


def check_patterns(file_path, content):
    """Check if file path or content matches any security patterns."""
    # Normalize path by removing leading slashes
    normalized_path = file_path.lstrip("/")

    for pattern in SECURITY_PATTERNS:
        # Check path-based patterns
        if "path_check" in pattern and pattern["path_check"](normalized_path):
            return pattern["ruleName"], pattern["reminder"]

        # Check content-based patterns
        if "substrings" in pattern and content:
            for substring in pattern["substrings"]:
                if substring in content:
                    return pattern["ruleName"], pattern["reminder"]

    return None, None


def extract_content_from_input(tool_name, tool_input):
    """Extract content to check from tool input based on tool type."""
    if tool_name == "Write":
        return tool_input.get("content", "")
    elif tool_name == "Edit":
        return tool_input.get("new_string", "")
    elif tool_name == "MultiEdit":
        edits = tool_input.get("edits", [])
        if edits:
            return " ".join(edit.get("new_string", "") for edit in edits)
        return ""

    return ""


def main():
    """Main hook function."""
    # Check if security reminders are enabled
    security_reminder_enabled = os.environ.get("ENABLE_SECURITY_REMINDER", "1")

    # Only run if security reminders are enabled
    if security_reminder_enabled == "0":
        sys.exit(0)

    # Periodically clean up old state files (10% chance per run)
    if random.random() < 0.1:
        cleanup_old_state_files()

    # Read input from stdin
    try:
        raw_input = sys.stdin.read()
        input_data = json.loads(raw_input)
    except json.JSONDecodeError as e:
        debug_log(f"JSON decode error: {e}")
        # Exit code 0: Allow tool to proceed if we can't parse input (fail-safe)
        sys.exit(0)

    # Extract session ID and tool information from the hook input
    session_id = input_data.get("session_id", "default")
    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Check if this is a relevant tool
    if tool_name not in ["Edit", "Write", "MultiEdit"]:
        # Exit code 0: Allow non-file tools to proceed
        sys.exit(0)

    # Extract file path from tool_input
    file_path = tool_input.get("file_path", "")
    if not file_path:
        # Exit code 0: Allow if no file path
        sys.exit(0)

    # Extract content to check
    content = extract_content_from_input(tool_name, tool_input)

    # Check for security patterns
    rule_name, reminder = check_patterns(file_path, content)

    if rule_name and reminder:
        # Create unique warning key
        warning_key = f"{file_path}-{rule_name}"

        # Load existing warnings for this session
        shown_warnings = load_state(session_id)

        # Check if we've already shown this warning in this session
        if warning_key not in shown_warnings:
            # Add to shown warnings and save
            shown_warnings.add(warning_key)
            save_state(session_id, shown_warnings)

            # Output the warning to stderr and block execution
            print(reminder, file=sys.stderr)
            # Exit code 2: Block tool execution (sends warning to Claude)
            sys.exit(2)

    # Exit code 0: Allow tool to proceed (no security issues detected)
    sys.exit(0)


if __name__ == "__main__":
    main()
