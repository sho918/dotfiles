---
name: merge-remote-default-branch
description: Use when a user asks to merge, take in, sync, or resolve conflicts from main/master/default branch, including "main を取り込んで", "master を取り込んで", "merge main", "merge master", or branch conflict resolution.
---

# Merge Remote Default Branch

## Overview

Merge the latest remote-tracking default branch into the current work branch. Core rule: fetch and merge `origin/main`, `origin/master`, or the remote default ref; never trust stale local `main` / `master` unless explicitly requested.

Normal merge is the default. Rebase, squash, local-base merges, and push require explicit user direction.

## Workflow

1. Confirm state:
   ```bash
   git status --short --branch
   git branch --show-current
   git remote -v
   ```
   Stop on `main`, `master`, or detached HEAD unless explicitly requested. Ask if unrelated dirty changes cannot be isolated.

2. Select and fetch the remote target:
   - `main` request -> `git fetch origin main`, then `origin/main`
   - `master` request -> `git fetch origin master`, then `origin/master`
   - default/latest-base request -> inspect remote default, fetch it, then `origin/<branch>`
   - both `origin/main` and `origin/master` exist with unclear intent -> ask
   ```bash
   git remote show origin
   git fetch origin <branch>
   git rev-parse --verify origin/<branch>
   ```

3. Preflight conflict surface:
   ```bash
   git merge-tree --write-tree HEAD origin/<branch>
   git diff --name-only HEAD...origin/<branch>
   ```
   Fall back to `git merge-tree HEAD origin/<branch>` if needed.

4. Merge without auto-commit:
   ```bash
   git merge --no-ff --no-commit origin/<branch>
   ```
   If already up to date, report and stop.

5. Resolve conflicts:
   ```bash
   git diff --name-only --diff-filter=U
   git show :1:path/to/file
   git show :2:path/to/file
   git show :3:path/to/file
   ```
   Preserve branch intent inside remote-side structure. Do not blindly choose `--ours`, `--theirs`, `-X ours`, or `-X theirs` for renamed, generated, schema, lockfile, route, or API files. `このブランチ優先` means branch behavior wins, not old structure.

6. Check markers, whitespace, and semantic leftovers:
   ```bash
   rg -n '<<<<<<<|=======|>>>>>>>' .
   git diff --check
   git status --short
   ```
   Scan touched files for stale names, duplicate imports, generated drift, lockfile inconsistency, route/schema drift, and old assertions.

7. Run focused repo-native verification for touched surfaces. Caveat skipped, blocked, interrupted, or environment-limited checks.

8. Commit after verification:
   ```bash
   git add <resolved-files>
   git commit -m "chore(repo): merge origin <branch>"
   ```
   Use the repo's existing commit style when obvious.

9. Push only if the user asked for push, PR, or full follow-through:
   ```bash
   git push
   git status --short --branch
   ```
   Otherwise stop after the local merge commit.

## Quick Reference

| Situation | Action |
| --- | --- |
| `main を取り込んで` | Fetch and merge `origin/main` |
| `master を取り込んで` | Fetch and merge `origin/master` |
| Local `main` / `master` is stale | Ignore it; use fetched `origin/<branch>` |
| `このブランチ優先` | Preserve branch behavior inside remote-side structure |
| Conflict markers removed | Still run semantic searches |
| User did not mention push | Create local merge commit only |

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Merging local `main` / `master` because it exists | Fetch and merge `origin/<branch>` unless local was explicitly requested |
| Treating marker removal as completion | Search for stale names, generated drift, and failing assertions |
| Using `-X ours` to honor "branch wins" | Preserve branch intent manually when remote refactors moved the code |
| Auto-pushing after a merge request | Push only when the user asked for push, PR, or full publish follow-through |
| Reporting green without evidence | List exactly which verification ran and which checks were skipped or blocked |
