#!/usr/bin/env python3
"""
Script to create GitHub issues from backlog markdown files.
Creates issues with proper parent-child relationships, traceability, and execution order.
"""

import os
import re
import json
import subprocess
from typing import Dict, List, Optional, Tuple

# Constants
DEFAULT_REPO = os.environ.get('GITHUB_REPOSITORY', 'siddjoshi/EDUTrack-Demo')
CONTENT_TRUNCATE_LENGTH = 2000

# Compiled regex patterns for performance
ITEM_ID_PATTERN = re.compile(r'\|\s*(?:Epic ID|Feature ID|Story ID|Task ID)\s*\|\s*([A-Z]+-\d+)')
TITLE_PATTERN = re.compile(r'^#\s+(.+)$', re.MULTILINE)
TARGET_RELEASE_PATTERN = re.compile(r'\|\s*Target Release / PI\s*\|\s*([^|]+)\|')
STATUS_PATTERN = re.compile(r'\|\s*(?:Current )?Status\s*\|\s*([^|]+)\|')
ASSIGNED_TO_PATTERN = re.compile(r'\|\s*Assigned To\s*\|\s*([^|]+)\|')
STORY_POINTS_PATTERN = re.compile(r'\|\s*Story Points\s*\|\s*(\d+)')

class BacklogItem:
    """Represents a backlog item (Epic, Feature, Story, or Task)"""
    
    def __init__(self, filepath: str):
        self.filepath = filepath
        self.content = self._read_file()
        self.item_type = self._determine_type()
        self.item_id = self._extract_id()
        self.title = self._extract_title()
        self.metadata = self._extract_metadata()
        self.parent_id = self._extract_parent()
        self.linked_items = self._extract_linked_items()
        self.dependencies = self._extract_dependencies()
        self.priority = self._extract_priority()
        self.labels = self._generate_labels()
        self.issue_number = None  # Will be set after creation
        
    def _read_file(self) -> str:
        """Read the markdown file content"""
        try:
            with open(self.filepath, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            raise FileNotFoundError(f"Backlog file not found: {self.filepath}")
        except PermissionError:
            raise PermissionError(f"Permission denied reading file: {self.filepath}")
        except Exception as e:
            raise IOError(f"Error reading file {self.filepath}: {e}")
    
    def _determine_type(self) -> str:
        """Determine if this is an Epic, Feature, Story, or Task"""
        if '/epics/' in self.filepath:
            return 'epic'
        elif '/features/' in self.filepath:
            return 'feature'
        elif '/stories/' in self.filepath:
            return 'story'
        elif '/tasks/' in self.filepath:
            return 'task'
        return 'unknown'
    
    def _extract_id(self) -> str:
        """Extract the item ID (e.g., EP-0001, FE-0001, US-0001, TSK-0001)"""
        # Look for ID in metadata table
        match = ITEM_ID_PATTERN.search(self.content)
        if match:
            return match.group(1)
        
        # Fallback: extract from filename
        filename = os.path.basename(self.filepath)
        match = re.match(r'([A-Z]+-\d+)', filename)
        if match:
            return match.group(1)
        
        return 'UNKNOWN'
    
    def _extract_title(self) -> str:
        """Extract the title from the first heading"""
        match = TITLE_PATTERN.search(self.content)
        if match:
            title = match.group(1).strip()
            # Remove prefixes like "Epic Blueprint:", "Feature Specification:", etc.
            title = re.sub(r'^(Epic Blueprint|Feature Specification|User Story Specification|Task Specification):\s*', '', title)
            return title
        return 'Untitled'
    
    def _extract_metadata(self) -> Dict[str, str]:
        """Extract metadata from the document"""
        metadata = {}
        
        # Define metadata field patterns
        metadata_fields = [
            ('target_release', TARGET_RELEASE_PATTERN),
            ('status', STATUS_PATTERN),
            ('assigned_to', ASSIGNED_TO_PATTERN),
            ('story_points', STORY_POINTS_PATTERN),
        ]
        
        for field_name, pattern in metadata_fields:
            match = pattern.search(self.content)
            if match:
                metadata[field_name] = match.group(1).strip()
        
        return metadata
    
    def _extract_parent(self) -> Optional[str]:
        """Extract parent item ID"""
        # Look for parent references in metadata
        patterns = [
            r'\|\s*Epic / Initiative Link\s*\|\s*([A-Z]+-\d+)',
            r'\|\s*Feature / Capability\s*\|\s*([A-Z]+-\d+)',
            r'\|\s*Parent Story\s*\|\s*([A-Z]+-\d+)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, self.content)
            if match:
                return match.group(1)
        
        return None
    
    def _extract_linked_items(self) -> Dict[str, List[str]]:
        """Extract linked items (features, stories, tasks)"""
        linked = {
            'features': [],
            'stories': [],
            'tasks': []
        }
        
        # Extract feature references (FE-XXXX)
        features = re.findall(r'\b(FE-\d{4})\b', self.content)
        linked['features'] = list(set(features))
        
        # Extract story references (US-XXXX)
        stories = re.findall(r'\b(US-\d{4})\b', self.content)
        linked['stories'] = list(set(stories))
        
        # Extract task references (TSK-XXXX)
        tasks = re.findall(r'\b(TSK-\d{4})\b', self.content)
        linked['tasks'] = list(set(tasks))
        
        return linked
    
    def _extract_dependencies(self) -> List[Dict[str, str]]:
        """Extract task dependencies"""
        dependencies = []
        
        # Look for dependencies section
        dep_section = re.search(r'## \d+\. Dependencies.*?(?=##|\Z)', self.content, re.DOTALL)
        if dep_section:
            # Extract task dependencies from tables
            dep_matches = re.finditer(r'(TSK-\d{4})', dep_section.group(0))
            for match in dep_matches:
                dependencies.append({
                    'task_id': match.group(1),
                    'type': 'blocking'
                })
        
        return dependencies
    
    def _extract_priority(self) -> str:
        """Extract priority level"""
        match = re.search(r'\|\s*Priority\s*\|\s*([^|]+)\|', self.content)
        if match:
            priority = match.group(1).strip().lower()
            if 'critical' in priority or 'must have' in priority:
                return 'critical'
            elif 'high' in priority or 'should have' in priority:
                return 'high'
            elif 'medium' in priority:
                return 'medium'
            return 'low'
        
        # Default priority based on type
        if self.item_type == 'epic':
            return 'critical'
        elif self.item_type == 'feature':
            return 'high'
        return 'medium'
    
    def _generate_labels(self) -> List[str]:
        """Generate appropriate labels for the issue"""
        labels = [self.item_type]
        
        # Add priority label
        labels.append(f'priority:{self.priority}')
        
        # Add status label
        status = self.metadata.get('status', 'Ready').lower()
        if 'ready' in status:
            labels.append('status:ready')
        elif 'in progress' in status or 'to do' in status:
            labels.append('status:todo')
        
        # Add sprint/release label
        target = self.metadata.get('target_release', '')
        if 'Sprint 1' in target or 'Sprint 2' in target:
            labels.append('sprint:1-2')
        elif 'MVP' in target or 'Q2 2026' in target:
            labels.append('release:mvp')
        
        return labels
    
    def create_issue_body(self, parent_issue: Optional[int] = None) -> str:
        """Create formatted issue body with metadata and content"""
        body_parts = []
        
        # Add parent reference if exists
        if parent_issue:
            body_parts.append(f"**Parent:** #{parent_issue}")
        
        # Add metadata
        if self.metadata:
            body_parts.append("## Metadata")
            if 'target_release' in self.metadata:
                body_parts.append(f"- **Target Release:** {self.metadata['target_release']}")
            if 'status' in self.metadata:
                body_parts.append(f"- **Status:** {self.metadata['status']}")
            if 'assigned_to' in self.metadata:
                body_parts.append(f"- **Assigned To:** {self.metadata['assigned_to']}")
            if 'story_points' in self.metadata:
                body_parts.append(f"- **Story Points:** {self.metadata['story_points']}")
        
        # Add traceability section
        body_parts.append("\n## Traceability")
        body_parts.append(f"- **Item ID:** {self.item_id}")
        body_parts.append(f"- **Backlog File:** `{os.path.relpath(self.filepath)}`")
        
        # Add linked items
        if any(self.linked_items.values()):
            body_parts.append("\n## Linked Items")
            if self.linked_items['features']:
                body_parts.append(f"- **Features:** {', '.join(self.linked_items['features'])}")
            if self.linked_items['stories']:
                body_parts.append(f"- **Stories:** {', '.join(self.linked_items['stories'])}")
            if self.linked_items['tasks']:
                body_parts.append(f"- **Tasks:** {', '.join(self.linked_items['tasks'])}")
        
        # Add dependencies
        if self.dependencies:
            body_parts.append("\n## Dependencies")
            for dep in self.dependencies:
                body_parts.append(f"- {dep['task_id']} ({dep['type']})")
        
        # Add link to full document
        body_parts.append(f"\n---\n📄 **Full Documentation:** See [`{os.path.basename(self.filepath)}`]({os.path.relpath(self.filepath)})")
        
        # Add truncated content (first CONTENT_TRUNCATE_LENGTH characters of main content)
        # Remove metadata tables and keep main content
        content_parts = re.split(r'##\s+\d+\.', self.content)
        if len(content_parts) > 1:
            # Find executive summary or main description
            for part in content_parts[1:5]:  # Check first few sections
                if any(keyword in part.lower() for keyword in ['executive summary', 'objective', 'business context', 'description']):
                    # Clean up the section
                    section = part[:CONTENT_TRUNCATE_LENGTH].strip()
                    body_parts.append(f"\n## Overview\n{section}")
                    break
        
        return '\n'.join(body_parts)


def create_github_issue(item: BacklogItem, parent_issue: Optional[int] = None, repo: str = None) -> Optional[int]:
    """Create a GitHub issue using gh CLI"""
    if not repo:
        repo = get_github_repo()
    
    title = f"[{item.item_id}] {item.title}"
    body = item.create_issue_body(parent_issue)
    labels = ','.join(item.labels)
    
    # Create issue using gh CLI
    cmd = [
        'gh', 'issue', 'create',
        '--repo', repo,
        '--title', title,
        '--body', body,
        '--label', labels
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        # Extract issue number from URL in output
        match = re.search(r'/issues/(\d+)', result.stdout)
        if match:
            issue_number = int(match.group(1))
            print(f"✅ Created issue #{issue_number}: {title}")
            return issue_number
        else:
            print(f"⚠️  Created issue but couldn't extract number: {title}")
            return None
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to create issue for {item.item_id}: {e.stderr}")
        return None


def get_github_repo() -> str:
    """Get the GitHub repository from git remote or environment"""
    try:
        result = subprocess.run(
            ['git', 'config', '--get', 'remote.origin.url'],
            capture_output=True, text=True, check=True
        )
        url = result.stdout.strip()
        # Extract owner/repo from URL
        match = re.search(r'github\.com[:/](.+/.+?)(?:\.git)?$', url)
        if match:
            return match.group(1)
    except subprocess.CalledProcessError:
        pass
    
    return DEFAULT_REPO


def collect_backlog_items(backlog_dir: str) -> Dict[str, List[BacklogItem]]:
    """Collect all backlog items organized by type"""
    items = {
        'epics': [],
        'features': [],
        'stories': [],
        'tasks': []
    }
    
    for category in items.keys():
        category_dir = os.path.join(backlog_dir, category)
        if not os.path.exists(category_dir):
            print(f"⚠️  Warning: Directory not found: {category_dir}")
            continue
        
        try:
            filenames = sorted(os.listdir(category_dir))
        except PermissionError:
            print(f"❌ Error: Permission denied accessing directory: {category_dir}")
            continue
        except OSError as e:
            print(f"❌ Error: Failed to list directory {category_dir}: {e}")
            continue
        
        for filename in filenames:
            if filename.endswith('.md'):
                filepath = os.path.join(category_dir, filename)
                try:
                    item = BacklogItem(filepath)
                    items[category].append(item)
                except (FileNotFoundError, PermissionError, IOError) as e:
                    print(f"⚠️  Warning: Skipping {filepath}: {e}")
                    continue
    
    return items


def create_all_issues(backlog_dir: str, dry_run: bool = False):
    """Create GitHub issues for all backlog items with proper hierarchy"""
    print("🔍 Collecting backlog items...")
    items = collect_backlog_items(backlog_dir)
    
    # Count items
    total = sum(len(items[cat]) for cat in items)
    print(f"📊 Found {total} backlog items:")
    for category, item_list in items.items():
        print(f"   - {len(item_list)} {category}")
    
    if dry_run:
        print("\n🧪 DRY RUN MODE - No issues will be created")
        print("\nWould create the following issues:")
        for category in ['epics', 'features', 'stories', 'tasks']:
            for item in items[category]:
                print(f"  [{item.item_id}] {item.title} (labels: {', '.join(item.labels)})")
        return
    
    print(f"\n📝 Creating GitHub issues...")
    
    # Track created issues
    issue_map = {}  # item_id -> issue_number
    
    # Create in order: Epics -> Features -> Stories -> Tasks
    for category in ['epics', 'features', 'stories', 'tasks']:
        print(f"\n📌 Creating {category}...")
        for item in items[category]:
            # Find parent issue number if exists
            parent_issue = None
            if item.parent_id and item.parent_id in issue_map:
                parent_issue = issue_map[item.parent_id]
            
            # Create the issue
            issue_number = create_github_issue(item, parent_issue)
            if issue_number:
                issue_map[item.item_id] = issue_number
                item.issue_number = issue_number
    
    # Create summary
    print(f"\n✨ Summary:")
    print(f"   Created {len(issue_map)} GitHub issues")
    print(f"\n🔗 Issue Mapping:")
    for item_id, issue_num in sorted(issue_map.items()):
        print(f"   {item_id} -> Issue #{issue_num}")
    
    # Save mapping to file
    mapping_file = os.path.join(backlog_dir, 'issue-mapping.json')
    try:
        os.makedirs(os.path.dirname(mapping_file), exist_ok=True)
        with open(mapping_file, 'w') as f:
            json.dump(issue_map, f, indent=2)
        print(f"\n💾 Saved issue mapping to: {mapping_file}")
    except (IOError, OSError) as e:
        print(f"⚠️  Warning: Could not save issue mapping to {mapping_file}: {e}")
        print(f"   Issue mapping: {json.dumps(issue_map, indent=2)}")


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Create GitHub issues from backlog markdown files')
    parser.add_argument('--backlog-dir', default='./backlog', help='Path to backlog directory')
    parser.add_argument('--dry-run', action='store_true', help='Preview without creating issues')
    
    args = parser.parse_args()
    
    # Check if gh CLI is installed
    try:
        subprocess.run(['gh', '--version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Error: GitHub CLI (gh) is not installed or not in PATH")
        print("   Install from: https://cli.github.com/")
        return 1
    
    # Check if authenticated
    try:
        subprocess.run(['gh', 'auth', 'status'], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        print("❌ Error: Not authenticated with GitHub CLI")
        print("   Run: gh auth login")
        return 1
    
    # Resolve backlog directory
    backlog_dir = os.path.abspath(args.backlog_dir)
    if not os.path.exists(backlog_dir):
        print(f"❌ Error: Backlog directory not found: {backlog_dir}")
        return 1
    
    print(f"📂 Backlog directory: {backlog_dir}")
    
    create_all_issues(backlog_dir, args.dry_run)
    
    print("\n✅ Done!")
    return 0


if __name__ == '__main__':
    exit(main())
