---
name: changelog-generator
description: Generate and maintain CHANGELOG.md files following Keep a Changelog format. Use when user asks to create changelog, update release notes, document version changes, or generate change history from git commits.
---

# Changelog Generator Skill

This skill helps create and maintain CHANGELOG.md files following the [Keep a Changelog](https://keepachangelog.com/) format.

## Capabilities

- Generate CHANGELOG.md from git commit history
- Update existing changelogs with new entries
- Follow semantic versioning principles
- Categorize changes appropriately
- Format according to Keep a Changelog standards

## When to Use This Skill

Activate this skill when the user requests:
- "Generate a changelog"
- "Update CHANGELOG.md"
- "Create release notes"
- "Document version changes"
- "Generate change history"

## Changelog Format

Follow the Keep a Changelog format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes and improvements

## [1.0.0] - 2024-01-01

### Added
- Initial release features
```

## Change Categories

Categorize changes using these standard types:

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

## Best Practices

1. **Parse git history**: Use `git log` to identify commits since last release
2. **Group by type**: Organize changes into appropriate categories
3. **Be descriptive**: Write clear, user-focused descriptions
4. **Link to issues**: Include issue/PR references when available
5. **Follow semver**: Suggest appropriate version numbers based on changes
6. **Keep chronological**: Most recent changes at the top
7. **Date format**: Use ISO date format (YYYY-MM-DD)

## Commit Message Parsing

Extract change types from commit messages:
- `feat:` or `feature:` → Added
- `fix:` or `bugfix:` → Fixed
- `docs:` → Changed (if documentation)
- `refactor:` → Changed
- `perf:` → Changed
- `security:` → Security
- `breaking:` or `BREAKING CHANGE:` → Changed (note as breaking)

## Workflow

1. Check if CHANGELOG.md exists
2. If not, create new file with proper header
3. Analyze git commits since last tag/release
4. Categorize commits by type
5. Generate entries in appropriate sections
6. Suggest version number based on changes
7. Update or append to CHANGELOG.md
