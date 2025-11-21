# GitHub Actions Workflows

## validate-plugins.yml

Automated validation workflow for plugin configurations.

### What It Does

This workflow automatically validates all plugin configurations to ensure:

- ✅ **JSON Syntax**: All JSON files are syntactically valid
- ✅ **Schema Compliance**: Plugin configurations follow official Claude Code specifications
- ✅ **Hook Structures**: Hooks use correct structure for lifecycle and tool-based events
- ✅ **Metadata Completeness**: Required and recommended fields are present
- ✅ **Code Quality**: No trailing commas, proper formatting
- ✅ **Security**: No obvious secrets or credentials in configurations

### When It Runs

The workflow runs automatically on:

1. **Pull Requests** - When plugin configurations are modified
2. **Pushes to main branches** - When changes are merged
3. **Manual Trigger** - Can be run manually from GitHub Actions tab

### Jobs

#### 1. Validate (Primary)
- Runs `Script/validate-all.sh` to check all configurations
- Comments on PRs with results
- Uploads validation reports on failure

#### 2. Lint JSON
- Validates JSON syntax with `jq`
- Checks for trailing commas (JSON spec violation)
- Warns about tabs in JSON files (style issue)

#### 3. Security Check
- Scans for potential secrets in configurations
- Checks for API keys, passwords, tokens
- Informational only - doesn't block merge

#### 4. Summary
- Aggregates results from all jobs
- Provides overall pass/fail status
- Links to documentation for fixes

### Best Practices

1. **Run Locally First**: Always run `./Script/validate-all.sh` before pushing
2. **Fix Before Push**: Address validation errors before creating PR
3. **Review Comments**: Check PR comments for detailed error information
4. **Use Pre-Commit Hook**: Install with `./Script/install-git-hooks.sh`

### Workflow Features

#### Security
- ✅ Minimal permissions (least privilege principle)
- ✅ Pinned action versions (no @latest)
- ✅ Secrets scanning
- ✅ Read-only by default

#### Performance
- ✅ Caching for jq installation
- ✅ Concurrency control (cancels outdated runs)
- ✅ Path filtering (only runs when needed)
- ✅ Parallel job execution

#### Developer Experience
- ✅ Clear error messages
- ✅ PR comments with results
- ✅ Downloadable validation reports
- ✅ Job summaries with links to docs
- ✅ Manual trigger option

### Adding Status Badge

Add this badge to your README.md to show validation status:

```markdown
[![Validate Plugins](https://github.com/xrf9268-hue/claude-code-plugins/actions/workflows/validate-plugins.yml/badge.svg)](https://github.com/xrf9268-hue/claude-code-plugins/actions/workflows/validate-plugins.yml)
```

### Troubleshooting

#### Workflow Not Running
- Check that file paths in `paths:` filter match your changes
- Ensure you have Actions enabled in repository settings

#### Validation Fails in CI but Passes Locally
- Ensure you're using same version of `jq`
- Check for line ending differences (CRLF vs LF)
- Verify all files are committed

#### Permission Errors
- Workflow needs `contents: read` and `pull-requests: write`
- Check repository Actions settings

### Customization

To modify the workflow:

1. Edit `.github/workflows/validate-plugins.yml`
2. Test changes with manual trigger first
3. Adjust paths filter for your needs
4. Add/remove jobs as needed
5. Update permissions if adding new features

### Related Documentation

- [Plugin Maintenance Guide](../../docs/PLUGIN_MAINTENANCE_GUIDE.md)
- [Implementation Plan](../../IMPLEMENTATION_PLAN.md)
- [Improvement Changelog](../../docs/IMPROVEMENT_CHANGELOG.md)

### Support

For issues with this workflow:
1. Check workflow run logs in GitHub Actions tab
2. Download validation report artifact
3. Review [Plugin Maintenance Guide](../../docs/PLUGIN_MAINTENANCE_GUIDE.md)
4. Open an issue with workflow run link
