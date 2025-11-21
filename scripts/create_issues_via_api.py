#!/usr/bin/env python3
"""
Script to create GitHub issues using GitHub REST API.
This version uses git credential helper or environment token for authentication.
"""

import os
import json
import subprocess
import sys
import urllib.request
import urllib.error
from typing import Dict, List, Optional

# Add the scripts directory to path
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)
from create_github_issues import BacklogItem, collect_backlog_items, DEFAULT_REPO

# Git credential helper protocol format
# See: https://git-scm.com/docs/git-credential
GIT_CREDENTIAL_INPUT = "protocol=https\nhost=github.com\n\n"

# Valid GitHub hosts for URL validation
GITHUB_HOSTS = ['github.com/', 'github.com:', '@github.com']

def get_github_token() -> Optional[str]:
    """Get GitHub token from git credential helper or environment"""
    # Try environment variable first
    token = os.environ.get('GITHUB_TOKEN') or os.environ.get('GH_TOKEN')
    if token:
        return token
    
    # Try to get from git credential helper
    try:
        # Get the git repository root
        result = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            capture_output=True, text=True, check=True
        )
        repo_root = result.stdout.strip()
        
        # Get the remote URL from the repo
        result = subprocess.run(
            ['git', 'config', '--get', 'remote.origin.url'],
            capture_output=True, text=True, check=True, cwd=repo_root
        )
        remote_url = result.stdout.strip()
        
        # Validate this is a genuine GitHub URL (not subdomain attack)
        if not any(host in remote_url for host in GITHUB_HOSTS):
            return None
        
        # Try git credential fill using the credential helper protocol
        result = subprocess.run(
            ['git', 'credential', 'fill'],
            input=GIT_CREDENTIAL_INPUT,
            capture_output=True, text=True, cwd=repo_root
        )
        
        # Parse credential output for password field
        for line in result.stdout.split('\n'):
            if line.startswith('password='):
                parts = line.split('=', 1)
                if len(parts) > 1:
                    password = parts[1].strip()
                    if password:  # Only return if not empty
                        return password
                    
    except subprocess.CalledProcessError as e:
        # Git command failed - likely not in a git repository
        pass
    except FileNotFoundError:
        # Git not installed
        pass
    except Exception:
        # Other unexpected errors - silently continue
        pass
    
    return None


def create_issue_via_api(repo: str, title: str, body: str, labels: List[str], token: str) -> Optional[int]:
    """Create a GitHub issue using the REST API"""
    url = f"https://api.github.com/repos/{repo}/issues"
    
    data = {
        "title": title,
        "body": body,
        "labels": labels
    }
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'EDUTrack-Issue-Creator'
    }
    
    try:
        request = urllib.request.Request(
            url,
            data=json.dumps(data).encode('utf-8'),
            headers=headers,
            method='POST'
        )
        
        with urllib.request.urlopen(request) as response:
            result = json.loads(response.read().decode('utf-8'))
            issue_number = result.get('number')
            print(f"✅ Created issue #{issue_number}: {title}")
            return issue_number
            
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        print(f"❌ Failed to create issue '{title}': HTTP {e.code}")
        print(f"   Error: {error_body}")
        return None
    except Exception as e:
        print(f"❌ Failed to create issue '{title}': {e}")
        return None


def main():
    """Main entry point"""
    print("🔍 GitHub Issue Creation via REST API")
    print("=" * 60)
    
    # Get GitHub token
    print("\n📋 Checking for GitHub authentication...")
    token = get_github_token()
    
    if not token:
        print("❌ Error: No GitHub authentication available")
        print("\nThis script needs a GitHub token to create issues.")
        print("\nPlease provide authentication via:")
        print("  1. Environment variable: export GITHUB_TOKEN=your_token")
        print("  2. Git credential helper (automatically used if configured)")
        print("\nTo create a token:")
        print("  - Go to: https://github.com/settings/tokens")
        print("  - Create a new token with 'repo' or 'public_repo' scope")
        print("  - Set it: export GITHUB_TOKEN=ghp_your_token_here")
        return 1
    
    print("✅ GitHub authentication found")
    
    # Get repository
    repo = os.environ.get('GITHUB_REPOSITORY', DEFAULT_REPO)
    print(f"📦 Repository: {repo}")
    
    # Collect backlog items
    print("\n🔍 Collecting backlog items...")
    
    # Get backlog directory - try multiple methods for robustness
    backlog_dir = None
    
    # Method 1: Use git repository root (most reliable)
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            capture_output=True, text=True, check=True
        )
        repo_root = result.stdout.strip()
        backlog_dir = os.path.join(repo_root, 'backlog')
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Method 2: Fallback to relative path from script location
        script_dir = os.path.dirname(os.path.abspath(__file__))
        repo_root = os.path.dirname(script_dir)
        backlog_dir = os.path.join(repo_root, 'backlog')
    
    if not os.path.exists(backlog_dir):
        print(f"❌ Error: Backlog directory not found: {backlog_dir}")
        print("\nPlease run this script from the repository root or ensure")
        print("the 'backlog' directory exists in the expected location.")
        return 1
    
    items = collect_backlog_items(backlog_dir)
    
    total = sum(len(items[cat]) for cat in items)
    print(f"📊 Found {total} backlog items:")
    for category, item_list in items.items():
        print(f"   - {len(item_list)} {category}")
    
    # Create issues in hierarchy order
    print(f"\n📝 Creating GitHub issues...")
    issue_map = {}  # item_id -> issue_number
    
    for category in ['epics', 'features', 'stories', 'tasks']:
        if not items[category]:
            continue
            
        print(f"\n📌 Creating {category}...")
        for item in items[category]:
            # Find parent issue number if exists
            parent_issue = None
            if item.parent_id and item.parent_id in issue_map:
                parent_issue = issue_map[item.parent_id]
            
            # Create issue
            title = f"[{item.item_id}] {item.title}"
            body = item.create_issue_body(parent_issue)
            
            issue_number = create_issue_via_api(
                repo=repo,
                title=title,
                body=body,
                labels=item.labels,
                token=token
            )
            
            if issue_number:
                issue_map[item.item_id] = issue_number
                item.issue_number = issue_number
    
    # Save mapping
    print(f"\n✨ Summary:")
    print(f"   Created {len(issue_map)} GitHub issues")
    print(f"\n🔗 Issue Mapping:")
    for item_id, issue_num in sorted(issue_map.items()):
        print(f"   {item_id} -> Issue #{issue_num}")
    
    # Save to file
    mapping_file = os.path.join(backlog_dir, 'issue-mapping.json')
    try:
        with open(mapping_file, 'w') as f:
            json.dump(issue_map, f, indent=2)
        print(f"\n💾 Saved issue mapping to: {mapping_file}")
    except Exception as e:
        print(f"⚠️  Warning: Could not save mapping: {e}")
    
    print("\n✅ Done!")
    return 0


if __name__ == '__main__':
    sys.exit(main())
