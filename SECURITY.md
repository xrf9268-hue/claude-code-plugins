# Security Policy

## Overview

Security is a top priority for the Claude Code Plugins project. This document outlines our security policy, including supported versions, how to report vulnerabilities, and our security practices.

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | :white_check_mark: | Current stable release |
| < 1.0   | :x:                | No longer supported |

## Reporting a Vulnerability

We take all security vulnerabilities seriously. If you discover a security vulnerability in this project, please report it responsibly.

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security vulnerabilities by emailing:

**Security Team:** support@anthropic.com

### What to Include

Please provide the following information in your report:

1. **Description** - A clear description of the vulnerability
2. **Impact** - What could an attacker achieve by exploiting this vulnerability?
3. **Steps to Reproduce** - Detailed steps to reproduce the vulnerability
4. **Affected Components** - Which plugin(s) or file(s) are affected?
5. **Suggested Fix** - If you have ideas on how to fix it (optional)
6. **Disclosure Timeline** - Your preferred disclosure timeline (optional)

### Example Report

```
Subject: Security Vulnerability in security-guidance plugin

Description:
The security_reminder_hook.py script is vulnerable to path traversal attacks
when processing file paths from tool_input.

Impact:
An attacker could potentially read files outside the project directory.

Steps to Reproduce:
1. Install security-guidance plugin
2. Use Edit tool with file_path: "../../../../etc/passwd"
3. Hook processes the path without validation

Affected Components:
- plugins/security-guidance/hooks/security_reminder_hook.py (line 544)

Suggested Fix:
Add path validation to ensure file_path is within project directory.
```

### Response Timeline

We aim to:

- **Acknowledge** your report within 48 hours
- **Provide an initial assessment** within 7 days
- **Issue a fix** within 30 days for critical vulnerabilities
- **Publicly disclose** the vulnerability after a fix is available (coordinated disclosure)

## Security Best Practices for Plugin Users

### Before Installing Plugins

1. **Review the Code** - All plugins in this repository are open source. Review the code before installation.
2. **Check Permissions** - Review what tools/permissions each plugin requests (especially `allowed-tools` in commands/agents)
3. **Read Documentation** - Understand what each plugin does before installing
4. **Verify Source** - Only install plugins from trusted sources

### Hook Security

**CRITICAL:** Claude Code hooks execute arbitrary shell commands on your system automatically.

When using plugins with hooks:

1. **Review Hook Scripts** - Examine all hook scripts before installation:
   - `plugins/*/hooks/*.sh`
   - `plugins/*/hooks/*.py`
   - `plugins/*/hooks/*.js`

2. **Understand Hook Behavior:**
   - **PreToolUse hooks** - Run before every matching tool execution
   - **PostToolUse hooks** - Run after every matching tool execution
   - **SessionStart hooks** - Run when Claude Code starts
   - **PreCompact hooks** - Run before conversation compaction

3. **Validate Inputs** - Hooks receive data from Claude. Ensure hooks validate all inputs.

4. **Check Exit Codes:**
   - Exit 0 = Allow operation
   - Exit 2 = Block operation (PreToolUse only)
   - Other = Warning, operation continues

### Current Hook-Based Plugins

| Plugin | Hook Type | Risk Level | Description |
|--------|-----------|------------|-------------|
| context-preservation | PreCompact, SessionStart | Low | Reads conversation, writes to `.claude/session-context/` |
| security-guidance | PreToolUse | Low | Reads file content for security patterns, blocks on issues |

**security-guidance plugin:**
- Blocks file edits containing security vulnerabilities
- Can be disabled with: `export ENABLE_SECURITY_REMINDER=0`
- State stored in: `~/.claude/security_warnings_state_{session_id}.json`

**context-preservation plugin:**
- Writes context to: `.claude/session-context/`
- No external network access
- Pure read/write operations

### Sensitive Data Handling

**Never commit sensitive data:**

- :x: API keys, tokens, passwords
- :x: Private keys, certificates
- :x: Database credentials
- :x: .env files with secrets
- :x: AWS credentials
- :x: SSH private keys

**Use .gitignore:**

The repository includes a comprehensive `.gitignore` that excludes:
- `.env` files
- Credential files
- Private keys
- State files
- Cache directories

### Tool Restrictions

Many commands and agents restrict tool access for security. Review `allowed-tools` fields:

**Example - commit command:**
```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
---
```

This restricts Claude to only git operations, preventing:
- File system modifications
- Network access
- Arbitrary command execution

### MCP Server Security

If you install MCP servers with these plugins:

1. **Vet Server Code** - Review the MCP server implementation
2. **Check Permissions** - Understand what the server can access
3. **Network Access** - Be cautious of servers that make network requests
4. **Trust** - Only install MCP servers from trusted sources

## Security Features in This Repository

### 1. Security-Guidance Plugin

Comprehensive security pattern detection covering 17 vulnerability types:

- Command injection (child_process.exec, os.system)
- Code injection (eval, new Function)
- XSS vulnerabilities (innerHTML, dangerouslySetInnerHTML, document.write)
- GitHub Actions workflow injection
- Unsafe deserialization (pickle)
- Frontend security issues (unsafe href, localStorage sensitive data)
- React-specific issues (refs DOM manipulation, key={index})
- CORS misconfiguration
- postMessage origin validation
- window.name XSS

### 2. Input Validation

All hook scripts validate inputs:

```python
# Example from security_reminder_hook.py
try:
    raw_input = sys.stdin.read()
    input_data = json.loads(raw_input)
except json.JSONDecodeError as e:
    debug_log(f"JSON decode error: {e}")
    sys.exit(0)  # Fail safely
```

### 3. Safe Error Handling

Hooks fail safely to avoid blocking Claude Code:

```python
# On error, exit 0 (don't block operation)
except Exception as e:
    sys.stderr.write(f"Hook error: {e}\n")
    sys.exit(0)  # Fail safely
```

### 4. Tool Restrictions

Commands and agents limit tool access:

```markdown
---
allowed-tools: Bash(git:*), Read, Grep
---
```

### 5. No Hardcoded Secrets

The codebase contains no hardcoded:
- API keys
- Passwords
- Tokens
- Credentials

### 6. CI/CD Security

GitHub Actions workflow includes:

- Secret pattern scanning
- JSON validation
- Hook structure validation
- File permission checking

## Known Security Considerations

### 1. Hook Execution Risk

**Risk:** Hooks execute automatically on events
**Mitigation:** All hooks in this repository are reviewed and validated
**User Action:** Review hook code before installation

### 2. GitHub CLI Dependency (code-review plugin)

**Risk:** code-review plugin uses GitHub CLI (`gh`) which requires authentication
**Mitigation:** Plugin only uses read-only `gh` commands for PR information
**User Action:** Ensure `gh` is properly authenticated: `gh auth status`

### 3. File System Access

**Risk:** Plugins can read/write files
**Mitigation:** Claude Code's permission system requires user approval
**User Action:** Review file operations before approving

### 4. Python/Node.js Dependencies

**Risk:** Hook scripts depend on system interpreters
**Mitigation:** Use standard libraries only (no external dependencies)
**User Action:** Ensure Python 3 and Node.js are from trusted sources

## Security Updates

We will publish security updates as follows:

1. **GitHub Security Advisories** - For vulnerabilities in this repository
2. **CHANGELOG.md** - Security fixes documented in changelog
3. **Git Tags** - Security releases tagged with version numbers
4. **Release Notes** - Detailed security information in releases

Subscribe to releases to receive security update notifications:
https://github.com/xrf9268-hue/claude-code-plugins/releases

## Responsible Disclosure

We practice coordinated vulnerability disclosure:

1. **Private Report** - Security researchers report vulnerabilities privately
2. **Fix Development** - We develop and test a fix
3. **Fix Release** - We release the fix
4. **Public Disclosure** - We publicly disclose the vulnerability after fix is available
5. **Credit** - We credit the reporter (if desired)

## Security Hall of Fame

We recognize security researchers who responsibly disclose vulnerabilities:

<!-- Will be updated as researchers report vulnerabilities -->

*No vulnerabilities reported yet.*

## Questions?

For security-related questions that are not vulnerabilities:

- **General Questions:** Open a GitHub Discussion
- **Documentation:** Check our security documentation in `docs/`
- **Contact:** support@anthropic.com

## Additional Resources

- [Claude Code Security Documentation](https://code.claude.com/docs/en/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

---

**Last Updated:** 2024-11-22

Thank you for helping keep Claude Code Plugins secure!
