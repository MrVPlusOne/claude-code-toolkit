# Claude Code Toolkit

A collection of reusable Claude Code configurations: custom agents, slash commands, and a multi-instance dashboard monitoring system.

## Contents

### Agents (`.claude/agents/`)

Custom agents that extend Claude Code's capabilities:

- **complexity-reducer** - Reviews code after major features are completed and suggests simplifications based on "A Philosophy of Software Design" principles
- **structural-refactor** - Splits large files into smaller, cohesive modules while preserving behavior

### Commands (`.claude/commands/`)

Custom slash commands:

- **/commit** - Creates git commits with auto-generated messages following Conventional Commits format
- **/rebase-branch** - Fetches remote changes, reviews new commits, and rebases local changes on top

### Dashboard (`dashboard/`)

A monitoring system for tracking multiple Claude Code instances across projects. Shows real-time status (working, waiting, permission needed) with optional push notifications.

## Installation

### Agents & Commands

Copy the `.claude/` directory to your project root:

```bash
cp -r .claude/ /path/to/your/project/
```

Or symlink for shared configuration:

```bash
ln -s /path/to/claude-code-toolkit/.claude /path/to/your/project/.claude
```

### Dashboard

Run the installer:

```bash
./dashboard/install.sh
```

See [dashboard/README.md](dashboard/README.md) for detailed setup instructions.

## Usage

### Agents

Agents are automatically available in Claude Code when placed in `.claude/agents/`. They're triggered based on context described in their metadata.

### Commands

Use slash commands in Claude Code:

```
/commit          # Auto-generate commit message and commit
/rebase-branch   # Fetch, review, and rebase
```

### Dashboard

Monitor all running Claude instances:

```bash
~/.claude/scripts/dashboard.sh --watch
```

## Requirements

- Claude Code CLI
- `jq` (for dashboard JSON processing)
- Pushover account (optional, for mobile notifications)
