---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
description: Create a git commit with an auto-generated message
---

## Context

- Current git status: !`git status`
- Staged changes: !`git diff --cached`
- Unstaged changes: !`git diff`
- Current branch: !`git branch --show-current`
- Recent commits for style reference: !`git log --oneline -5`

## Your task

1. **Analyze the changes**
   - Review both staged and unstaged changes
   - Understand the nature and purpose of the modifications

2. **Stage changes if needed**
   - If there are unstaged changes that should be committed, stage them with `git add`
   - Do not stage files that may contain secrets (.env, credentials, etc.)

3. **Generate a commit message**
   - Use Conventional Commits format: `type(scope): description`
   - Types: feat, fix, docs, style, refactor, test, chore
   - Keep the title under 50 characters
   - Add a body if the changes need more explanation (wrap at 72 chars)
   - Match the style of recent commits in this repo

4. **Create the commit**
   - Execute `git commit` with the generated message
   - DO NOT include any Claude co-authorship footer (per project guidelines)

## Constraints

- DO NOT add Claude co-authorship mentions to commits
- Do not commit files that should obviously not be commited, such as those containing secrets
- If there are no changes to commit, inform the user and stop
