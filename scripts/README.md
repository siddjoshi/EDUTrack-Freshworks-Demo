# GitHub Issue Creation Scripts

This directory contains scripts to create GitHub issues from the backlog markdown files.

## Scripts

### 1. `create_github_issues.py` (Recommended)

Uses GitHub CLI (`gh`) for authentication and issue creation.

**Prerequisites:**
- GitHub CLI installed: `brew install gh` or `sudo apt install gh`
- Authenticated: `gh auth login`

**Usage:**
```bash
# Preview what will be created (dry-run)
python3 scripts/create_github_issues.py --dry-run

# Create issues
python3 scripts/create_github_issues.py
```

**Features:**
- Interactive authentication via GitHub CLI
- Compiled regex for performance
- Comprehensive error handling
- Saves issue mapping to `backlog/issue-mapping.json`

---

### 2. `create_issues_via_api.py` (API Alternative)

Uses GitHub REST API directly with a personal access token.

**Prerequisites:**
- GitHub personal access token with `repo` or `public_repo` scope
- Create token at: https://github.com/settings/tokens

**Usage:**
```bash
# Set your token
export GITHUB_TOKEN=ghp_your_token_here

# Create issues
python3 scripts/create_issues_via_api.py
```

**Features:**
- Direct API calls (no CLI dependency)
- Works in CI/CD environments
- Token-based authentication
- Same output as CLI version

---

## Comparison

| Feature | create_github_issues.py | create_issues_via_api.py |
|---------|-------------------------|--------------------------|
| **Authentication** | GitHub CLI (OAuth) | Personal Access Token |
| **Dependencies** | Requires `gh` CLI | Python stdlib only |
| **Best For** | Interactive use | CI/CD, automation |
| **Setup** | `gh auth login` | `export GITHUB_TOKEN=...` |
| **Ease of Use** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐⭐ Moderate |

---

## Common Features

Both scripts:
- ✅ Parse all backlog markdown files (epics, features, stories, tasks)
- ✅ Extract metadata (ID, title, status, story points, assignee, etc.)
- ✅ Identify parent-child relationships
- ✅ Detect dependencies and linked items
- ✅ Generate proper labels (type, priority, status, sprint/release)
- ✅ Create issues in hierarchical order (Epic → Feature → Story → Task)
- ✅ Link parent issues using issue references
- ✅ Save issue mapping to `backlog/issue-mapping.json`
- ✅ Comprehensive error handling

---

## Output

After successful execution, both scripts will:

1. Create 6 GitHub issues:
   - 1 Epic (EP-0001)
   - 2 Features (FE-0001, FE-0002)
   - 1 Story (US-0001)
   - 2 Tasks (TSK-0001, TSK-0002)

2. Save issue mapping to `backlog/issue-mapping.json`:
   ```json
   {
     "EP-0001": 123,
     "FE-0001": 124,
     "FE-0002": 125,
     "US-0001": 126,
     "TSK-0001": 127,
     "TSK-0002": 128
   }
   ```

3. Display summary:
   ```
   ✨ Summary:
      Created 6 GitHub issues
   
   🔗 Issue Mapping:
      EP-0001 -> Issue #123
      FE-0001 -> Issue #124
      FE-0002 -> Issue #125
      US-0001 -> Issue #126
      TSK-0001 -> Issue #127
      TSK-0002 -> Issue #128
   ```

---

## Troubleshooting

### GitHub CLI Not Authenticated
```bash
# Run authentication
gh auth login

# Verify
gh auth status
```

### GitHub Token Not Working
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Check token scopes at:
# https://github.com/settings/tokens

# Token must have 'repo' or 'public_repo' scope
```

### API Rate Limits
If you encounter rate limiting:
- GitHub CLI: Uses authenticated rate limit (5000 requests/hour)
- API Token: Uses authenticated rate limit (5000 requests/hour)
- Both should be sufficient for creating 6 issues

### Permission Errors
If you get permission errors:
- Verify you have write access to the repository
- Check that your token has the correct scopes
- For organizations, ensure your token has access to the org

---

## Why Not Use MCP Server?

The current GitHub MCP (Model Context Protocol) server tools only support **read operations**:
- ✅ Search, list, and get issues/PRs/files
- ✅ Get workflow runs and job logs
- ❌ Create, update, or delete resources

For issue creation, you need direct GitHub authentication via CLI or API.

---

## Additional Resources

- **Manual Commands:** See `ISSUE_CREATION_COMMANDS.md` for copy-paste `gh` commands
- **Execution Plan:** See `EXECUTION_PLAN.md` for Sprint 1 planning
- **Backlog Guide:** See `backlog/README.md` for structure documentation
- **Implementation Summary:** See `IMPLEMENTATION_SUMMARY.md` for complete overview
