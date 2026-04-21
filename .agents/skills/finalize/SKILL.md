---
name: finalize
description: Finalize already-implemented GitHub pull request review fixes by verifying the work, creating an intentional commit, pushing the branch, replying to the corresponding review comments with immediately published REST inline replies that do not enter Pending review state, resolving the matching review threads, and confirming final thread state. Use when the user asks to finalize, commit and push, reply to review comments, resolve review threads, or complete end-to-end PR review cleanup after fixes are implemented.
---

# Finalize

## Overview

Finish review-fix work after implementation is complete: verify, commit, push, reply to the matching GitHub review comments as published single inline replies, resolve those review threads, and re-check the final state.

This skill is for finalization, not investigation. If the review feedback still needs triage or implementation, use a review-handling skill first, then return here.

## Progress Checklist

Copy this checklist and keep it updated:

```markdown
Finalize:
- [ ] Confirm branch, PR, and intended diff
- [ ] Fetch thread-aware review context
- [ ] Run relevant verification
- [ ] Commit intended changes
- [ ] Push branch
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

Stop and ask before continuing when any of these are true:

- The branch is `main`, `master`, or detached.
- The worktree contains unrelated changes that cannot be separated safely.
- No PR can be resolved from the user request or current branch.
- The user asked for review-fix implementation but the actual fixes are not done yet.

If the worktree is clean, continue only when the current HEAD already contains the review fixes that need to be pushed/replied/resolved.

## Step 2: Fetch Review Threads

Use the bundled read-only helper to fetch thread-aware state plus REST numeric comment IDs:

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

## Step 3: Verify and Commit

Run the smallest reliable verification set for the touched area before committing. Prefer existing project commands from scripts, task runners, or local docs. Always run:

```bash
git diff --check
```

Do not claim success when checks are skipped, blocked, timed out, or failing. Report the exact caveat instead.

Before committing:

1. Re-read `git diff` and `git status --porcelain`.
2. Stage only intended files.
3. Create a Conventional Commit.
4. If hooks rewrite files, inspect the new diff and make a follow-up commit when appropriate.

If no uncommitted changes exist, do not create an empty commit unless the user explicitly asks for one.

## Step 4: Push Safely

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

## Step 5: Reply Without Pending Review

After push succeeds, reply to each matching review comment using the REST pull request review-comment reply endpoint:

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
- Verification commands and outcomes.
- Review threads replied to and resolved.
- Any threads skipped, blocked, or still unresolved.
