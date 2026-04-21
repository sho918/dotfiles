---
name: finalize
description: Use when finalizing already-implemented GitHub review fixes, publishing a finished branch, creating a missing PR, replying to review comments, resolving review threads, or completing end-to-end PR cleanup after fixes are implemented.
---

# Finalize

## Overview

Finish review-fix work after implementation is complete: verify, publish the branch through `github:yeet` when available, reply to matching GitHub review comments as published single inline replies, resolve those review threads, and re-check the final state.

This skill is for finalization, not investigation. If the review feedback still needs triage or implementation, use a review-handling skill first, then return here.

For commit, push, and PR creation, use the `github:yeet` skill when it is available. The `finalize` constraints and the user's explicit instructions override `yeet` defaults: use English Semantic Commit style for commit messages and PR titles, write PR bodies in Japanese with at least `概要`, `影響範囲`, and `レビュー観点`, and default to a draft PR unless the user explicitly asks otherwise.

## Progress Checklist

Copy this checklist and keep it updated:

```markdown
Finalize:
- [ ] Confirm branch, PR, and intended diff
- [ ] Fetch existing thread-aware review context when a PR exists
- [ ] Run relevant verification
- [ ] Use `github:yeet` for commit, push, and PR creation when available
- [ ] Reply to matching review comments with REST inline replies
- [ ] Resolve matching review threads
- [ ] Re-fetch and confirm final state
```

## Step 1: Confirm Scope

Inspect the repository and branch before doing anything irreversible:

```bash
git status -sb
git status --porcelain
git branch --show-current
git remote -v
```

Resolve the PR from the user's URL/number when provided. Otherwise use local branch context:

```bash
gh pr view --json number,url,title,headRefName,baseRefName
```

If no PR can be resolved from the user request or current branch, do not stop just because the PR is missing. Record that PR creation is required, then inspect enough context to let `github:yeet` create it safely after commit and push:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
git branch --show-current
```

Use the repository default branch as the PR base unless the user request, branch naming, or repository metadata clearly indicates a different base.

Stop and ask before continuing when any of these are true:

- The branch is `main`, `master`, or detached.
- The worktree contains unrelated changes that cannot be separated safely.
- No PR exists and the PR base, title, or body cannot be inferred safely from the branch, diff, commits, and user request.
- The user asked for review-fix implementation but the actual fixes are not done yet.

If the worktree is clean, continue only when the current HEAD already contains the review fixes that need to be pushed/replied/resolved.

## Step 2: Fetch Review Threads

When a PR already exists, use the bundled read-only helper to fetch thread-aware state plus REST numeric comment IDs:

```bash
python .agents/skills/finalize/scripts/fetch_review_threads.py > /tmp/finalize-review-threads.json
```

For an explicit PR:

```bash
python .agents/skills/finalize/scripts/fetch_review_threads.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-review-threads.json
```

Use this output to identify each target thread's:

- GraphQL `thread.id` for `resolveReviewThread`.
- `isResolved` and `isOutdated`.
- file/path/line context.
- REST numeric `comment_rest_id` to use with the REST reply endpoint.

Do not rely on flat PR comments as the source of truth for inline review-thread state.

Target only threads that are unresolved, not outdated, and actually addressed by the current work or by a required explanation. Skip already-resolved and outdated threads unless the user explicitly asks to handle them.

If no PR exists yet, skip this step until after `github:yeet` creates the PR. Newly created PRs usually have no review threads; mark reply and resolve work as skipped unless the user provided an explicit review context to handle.

## Step 3: Verify and Publish with `github:yeet`

Run the smallest reliable verification set for the touched area before committing. Prefer existing project commands from scripts, task runners, or local docs. Always run:

```bash
git diff --check
```

Do not claim success when checks are skipped, blocked, timed out, or failing. Report the exact caveat instead.

When commit, push, or PR creation is needed, load and use `github:yeet` as the primary publish workflow. Give `yeet` these explicit constraints:

- Stage only intended files.
- Create an English Semantic Commit, such as `fix(api): handle missing review threads` or `docs(finalize): document PR creation fallback`.
- Push the current branch.
- Ensure a PR exists, creating one if missing.
- Use an English Semantic Commit PR title, such as `docs(finalize): add PR creation fallback`.
- Write the PR body in Japanese with at least `概要`, `影響範囲`, and `レビュー観点`.
- Include verification results honestly. If checks were skipped, blocked, timed out, or failed, say that clearly.
- Default to a draft PR unless the user explicitly requested a ready-for-review PR.

If no uncommitted changes exist, do not create an empty commit unless the user explicitly asks for one.

After `yeet` finishes, capture the PR number, PR URL, head branch, and pushed commit hash before continuing to review replies:

```bash
gh pr view --json number,url,title,headRefName,baseRefName
git rev-parse --short HEAD
```

If `github:yeet` is not available or cannot complete the publish flow, state why and use the fallback below only when the repository state is still safe.

## Step 4: Fallback Publish Flow

Use this fallback only when `github:yeet` is unavailable or blocked. Before committing:

1. Re-read `git diff` and `git status --porcelain`.
2. Stage only intended files.
3. Create an English Semantic Commit, such as `fix(api): handle missing review threads` or `docs(finalize): document PR creation fallback`.
4. If hooks rewrite files, inspect the new diff and make a follow-up commit when appropriate.

If no uncommitted changes exist, do not create an empty commit unless the user explicitly asks for one.

Before pushing, check whether the remote branch has moved:

```bash
git fetch origin
git status -sb
```

If the upstream branch is ahead or diverged, integrate the remote changes according to the repository's normal policy before pushing. Do not force-push unless the user explicitly requested it and it is safe for the branch.

Push the current branch with upstream tracking when needed:

```bash
git push -u origin HEAD
```

Record the pushed commit hash for the review replies:

```bash
git rev-parse --short HEAD
```

After push succeeds, re-check whether a PR exists for the current branch:

```bash
gh pr view --json number,url,title,headRefName,baseRefName
```

If no PR exists, create one. Default to a draft PR unless the user explicitly requested a ready-for-review PR.

PR creation rules:

- The title must be an English Semantic Commit title, such as `docs(finalize): add PR creation fallback`.
- The body must be Japanese and include at least `概要`, `影響範囲`, and `レビュー観点`.
- Include verification results honestly. If checks were skipped, blocked, timed out, or failed, say that clearly.

Use a body file so shell quoting cannot corrupt the PR text:

```bash
gh pr create \
  --draft \
  --base BASE_BRANCH \
  --head CURRENT_BRANCH \
  --title 'docs(finalize): add PR creation fallback' \
  --body-file /tmp/finalize-pr-body.md
```

After creation, capture the PR number and URL for review-thread operations and the final report:

```bash
gh pr view --json number,url,title,headRefName,baseRefName
```

## Step 5: Reply Without Pending Review

After `github:yeet` or the fallback publish flow succeeds, reply to each matching review comment using the REST pull request review-comment reply endpoint:

```bash
gh api \
  -X POST \
  "repos/OWNER/REPO/pulls/PULL_NUMBER/comments/COMMENT_ID/replies" \
  -f body='対応しました。

確認:
- `<command>`: <result>

反映コミット: <short-sha>'
```

`COMMENT_ID` must be the REST numeric review comment ID from `fetch_review_threads.py`, not the GraphQL node ID.

Keep replies short, specific, and tied to the thread:

- Say what changed or why no code change was required.
- Include only verification that actually ran.
- Include the pushed commit hash when there was a code change.

Never use these for review-thread replies in this workflow:

- `gh pr review`
- GraphQL `addPullRequestReview`
- GraphQL `addPullRequestReviewThreadReply`
- Any reply mutation that uses `pullRequestReviewId`

Those paths can create or modify pending reviews. The REST reply endpoint publishes a single inline reply immediately.

If a REST reply fails, stop for that thread and do not resolve it.

If there are no matching review threads, skip this step and state that no review replies were needed.

## Step 6: Resolve Threads

Resolve only after the matching REST reply succeeded:

```bash
gh api graphql \
  -F threadId=THREAD_NODE_ID \
  -f query='mutation($threadId: ID!) { resolveReviewThread(input: { threadId: $threadId }) { thread { id isResolved } } }'
```

Do not resolve a thread when:

- The reply failed.
- The pushed commit is missing or failed to push.
- The thread is unrelated to the current changes.
- The reviewer comment is still technically unresolved.

If there are no matching review threads, skip this step and state that no thread resolution was needed.

## Step 7: Confirm Final State

Re-run the helper:

```bash
python .agents/skills/finalize/scripts/fetch_review_threads.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-review-threads-after.json
```

Confirm every target thread has `isResolved: true`. Also confirm the final repo state:

```bash
git status -sb
```

Final reports must include:

- Commit hash and message, or explain why no commit was needed.
- Push result and branch.
- PR number and URL, including whether it was newly created.
- Verification commands and outcomes.
- Review threads replied to and resolved.
- Any threads skipped, blocked, or still unresolved.
