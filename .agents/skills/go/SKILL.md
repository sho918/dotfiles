---
name: go
description: Use when implementation is complete and the user wants a final hardening and publish pass before commit, push, or PR, especially when they mention Codex review, Claude Code /simplify, review loop, Ralph-style iteration, or no findings before shipping.
---

# Go

## Overview

Run a final review/simplification loop, fix every actionable finding, then commit, push, and open a draft PR only after both reviewers are clean in the same iteration.

This skill assumes Claude Code has a `/simplify` slash command available. Do not create or install a simplify skill as part of this workflow unless the user explicitly asks.

## Progress Checklist

Copy this checklist and keep it updated:

```markdown
Go:
- [ ] Confirm scope and base branch
- [ ] Run review/simplify loop until clean or blocked
- [ ] Run relevant verification
- [ ] Commit intended changes
- [ ] Push branch
- [ ] Open draft PR
```

## Step 1: Confirm Scope

Inspect the repository before running reviewers:

```bash
git status -sb
git status --porcelain
git branch --show-current
git remote -v
```

Determine the base branch from the user's request, the existing PR target, or the repository default branch. If the worktree contains unrelated changes, exclude them from review, commit, and PR scope. Ask the user only when you cannot separate intended and unrelated changes from the diff.

Do not continue to commit/push/PR from `main`, `master`, a detached HEAD, or an ambiguous branch without first creating or selecting the intended feature branch.

## Step 2: Run the Loop

Default loop limit: 3 iterations. Use a different limit only if the user explicitly sets one.

Each iteration must run in this order:

1. Run Codex review.
2. Fix every actionable Codex finding.
3. Run relevant verification after fixes.
4. Run Claude Code `/simplify`.
5. Apply only behavior-preserving simplifications or fix actionable simplify findings.
6. Run relevant verification after fixes.

Stop only when Codex review and Claude `/simplify` both report no actionable findings in the same iteration.

If the loop reaches the limit, stop without committing. Report the unresolved findings, last verification result, and why the loop could not complete.

## Codex Review

Choose the review target explicitly:

- For uncommitted implementation work: `codex review --uncommitted`
- For a branch diff against a base branch: `codex review --base <base-branch>`
- If committed branch work and uncommitted edits both exist, review both surfaces before treating Codex as clean.

Use `codex review` as read-only feedback. If it reports Critical or Important findings, fix them unless you can prove they are false positives. For false positives, record the technical reason and run the next full iteration; do not treat a single disputed finding as clean without another pass.

## Claude Code Simplify

Run Claude Code itself so the `/simplify` command is used. Keep the prompt constrained to behavior-preserving simplification and actionable findings.

Use this shape, adapting `<base-branch>` and scope details:

```bash
claude -p '/simplify
Review the current repository changes for simplification opportunities only.

Scope:
- Compare against <base-branch> when branch work exists.
- Include uncommitted changes when present.

Constraints:
- Do not commit, push, create branches, or open PRs.
- Do not change product behavior, public APIs, schemas, migrations, or generated files unless that is strictly required by a simplification finding.
- Prefer the smallest behavior-preserving simplification.
- If there are no actionable simplification findings, say exactly: NO_ACTIONABLE_SIMPLIFICATION.
- If you make edits, summarize changed files and why each edit preserves behavior.
'
```

After Claude returns:

- If it edited files, inspect `git diff` and run relevant verification.
- If it only reported findings, fix them yourself or run Claude again with a targeted `/simplify` prompt.
- Treat `NO_ACTIONABLE_SIMPLIFICATION` as clean only after checking that no files were unexpectedly changed.

If `/simplify` is unavailable, stop and tell the user that Claude Code does not expose the required command in this environment. Do not silently replace it with a generic Claude prompt.

## Verification Gate

Run the smallest reliable verification set for the touched area after every fix cycle and before committing. Prefer existing project commands from package scripts, task runners, or documented validation commands.

Do not claim completion when verification is skipped, blocked, timed out, or partially failing. If verification cannot run because of environment limits, report that plainly and do not open a PR unless the user explicitly accepts the risk.

## Step 3: Commit, Push, PR

After the loop is clean and verification is acceptable:

1. Re-check `git status -sb` and `git diff`.
2. Stage only intended files.
3. Create a Conventional Commit. Keep unrelated changes out.
4. Push the current branch with upstream tracking.
5. Open a draft PR unless the user explicitly requested ready-for-review.

Use local git for staging, committing, and pushing. Prefer the GitHub connector for PR creation when available; otherwise use `gh pr create --draft --fill` or an equivalent explicit title/body command.

The PR body must include:

- What changed
- Why it changed
- Review loop result, including Codex and Claude `/simplify`
- Verification commands and outcomes
- Any skipped checks or environment caveats

## Completion Rules

Only report success when all are true:

- Codex review has no actionable findings.
- Claude Code `/simplify` has no actionable findings.
- Relevant verification is passing or explicitly caveated.
- Commit and push succeeded.
- Draft PR URL is available.

If any item is false, report the exact blocker and current repository state instead of presenting the work as shipped.
