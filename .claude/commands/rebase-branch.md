---
allowed-tools: Bash(git fetch:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git rebase:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git stash:*)
description: Fetch remote changes and rebase local commits on top
---

## Context

- Current branch: !`git branch --show-current`
- Fetch result: !`git fetch 2>&1`
- Remote tracking branch: !`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "No upstream configured"`
- Working tree status: !`git status --short`
- Local commits not on remote: !`git log @{upstream}..HEAD --oneline 2>/dev/null || echo "No upstream or no local commits"`
- Remote commits not in local (after fetch): !`git log HEAD..@{upstream} --oneline 2>/dev/null || echo "No upstream or already up to date"`

## Your task
- If there's no upstream tracking branch configured, or there's no changes to rebase, inform the user and stop.
- If there are new commits on remote, read to understand them first. This helps you capture any potential semantic conflicts that slip through git rebase.
- If you have uncommited local changes, first commit them using the `/commit` command or stash them.
- Then rebase your local changes on top of the remote branch. Resolve any conflicts carefully, ensuring the final code is correct.

