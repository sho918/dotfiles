---
name: finalize
description: Use when a branch or GitHub pull request is ready for final completion, including SDD handoff, cleanup, CI failures, draft-to-ready transition, Copilot or Greptile feedback, review replies, or unresolved review threads.
---

# Finalize

## Overview

Drive a branch or PR to a finished GitHub state. This skill owns the final sequence: optional SDD verify/archive, deslop cleanup, local verification, publish, CI wait/fix loop, ready-for-review transition, Copilot/Greptile review wait, review-comment fixes, inline replies, thread resolution, and final state confirmation.

This skill may implement clear finalization fixes. Ask only when the next change is ambiguous, broad, conflicts with the user's scope, or would alter product behavior beyond review/CI cleanup.

Default loop limit: 3 cycles per stage. If CI or review feedback fails in the same stage 3 times, stop and report the exact state, evidence, and next required decision.

## Active Remote Wait Gate

Remote work that is still running is not a final state. After every PR state fetch, inspect `recommended_next_step`, visible check buckets/states, and detected bot signal statuses before deciding whether to end the turn.

Do not send a final report or `NOT_DONE` when any of these active states are present:

- `recommended_next_step` is `wait_for_ci` or `wait_for_bot_reviews`.
- Any required or detected check has bucket `pending`.
- Any relevant state is `QUEUED`, `IN_PROGRESS`, or `PENDING`.
- Any detected Copilot/Greptile signal has `status: pending`.

When the active wait gate is triggered, keep polling in the same turn. Give brief status updates about every 30 seconds, then re-run the state helper or `gh pr checks` until the state moves to success, failure, actionable review feedback, or a real blocker.

You may stop while remote work is active only when the user gave an explicit timebox or stop instruction, GitHub/API state cannot be queried after the documented fallback paths, or the same stage reached the 3-cycle failure limit. In that case, report the reason as blocked or timeboxed, not complete.

## Progress Checklist

Copy this checklist and keep it updated:

```markdown
Finalize:
- [ ] Confirm branch, PR, base, and intended diff
- [ ] Run SDD verify/archive when an active SDD change exists
- [ ] Run a scoped deslop cleanup
- [ ] Run local verification
- [ ] Commit, push, and ensure a draft PR exists
- [ ] Wait for CI and fix failures until green or blocked
- [ ] Mark the PR ready for review
- [ ] Wait for detected Copilot/Greptile review signals
- [ ] Address actionable review comments
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
gh pr view --json number,url,title,headRefName,baseRefName,isDraft,state
```

If no PR can be resolved, record that PR creation is required and inspect enough context to create it safely:

```bash
gh repo view --json nameWithOwner,defaultBranchRef
git branch --show-current
```

Use the repository default branch as the PR base unless the user request, branch naming, existing PR target, or repository metadata clearly indicates a different base.

Stop and ask before continuing when any of these are true:

- The branch is `main`, `master`, or detached and no safe feature branch/worktree is already selected.
- The worktree contains unrelated changes that cannot be separated safely.
- No PR exists and the PR base, title, or body cannot be inferred safely from the branch, diff, commits, and user request.
- A requested review/CI fix would change behavior outside the finalization scope.

If the worktree is clean, continue only when the current HEAD already contains the work that needs to be finalized.

## Step 2: SDD Verify and Archive Before Deslop

Before deslop, check whether the branch carries an active SDD change:

```bash
find docs/sdd/changes -mindepth 1 -maxdepth 1 -type d 2>/dev/null
git diff --name-only -- docs/sdd docs/product-specs
```

Run SDD finalization only when an active SDD change exists, the branch name/user request indicates SDD work, or the diff touches active SDD artifacts. If no active SDD work exists, record SDD as skipped.

When SDD applies:

- Use the repo's `sdd-verify` / `sdd-archive` skill or documented command when available.
- Treat `sdd-verify` as a hard gate. Do not archive if verification records a P1, failing requirement, or unresolved blocker.
- Archive only after verification is accepted as `verified`.
- Move verified changes from `docs/sdd/changes/<change-id>/` to `docs/sdd/archive/YYYY-MM-DD-<change-id>/` according to the repo convention.
- Update related durable product specs when the repo's SDD process expects it.
- Update archived `change.yaml` with `status: archived`, `verified_at`, and `archived_at` when those fields exist in local convention.
- If the PR URL does not exist yet, record that `delivery.pr_ref` must be filled after PR creation. After the PR exists, make a small follow-up commit that writes the PR URL into archived `change.yaml`.

After archive edits, run the repo formatter/checks that own the changed docs before moving to deslop.

## Step 3: Deslop and Local Verification

Run a scoped deslop pass after SDD verify/archive and before publishing:

- Load and use the `deslop` skill when available.
- Compare against the intended base branch, for example `git diff --stat origin/main...HEAD`.
- Remove only AI-generated slop introduced by the branch: unnecessary comments, abnormal defensive code, gratuitous casts, over-nested code, duplicated boilerplate, inflated wording, or redundant tests.
- Keep behavior unchanged unless fixing a clear bug.
- Do not run broad rewrites or repo-wide formatting unless the repo requires it for touched files.

Run the smallest reliable local verification set for the touched area. Always run:

```bash
git diff --check
```

Do not claim success when checks are skipped, blocked, timed out, or failing. Record the exact caveat.

## Step 4: Publish and Ensure Draft PR

When commit, push, or PR creation is needed, load and use `github:yeet` as the primary publish workflow. The constraints below override `yeet` defaults:

- Stage only intended files.
- Create an English Semantic Commit, such as `fix(api): handle missing review threads` or `docs(finalize): add CI completion flow`.
- Push the current branch.
- Ensure a PR exists, creating one if missing.
- Use an English Semantic Commit PR title.
- Write the PR body in Japanese with at least `概要`, `影響範囲`, and `レビュー観点`.
- Include verification results honestly, including skipped, blocked, timed-out, or failed checks.
- Default to a draft PR until CI is green.

If no uncommitted changes exist, do not create an empty commit unless the user explicitly asks for one.

After publish, capture the PR number, URL, head branch, base branch, and pushed commit:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,isDraft
git rev-parse --short HEAD
```

If `github:yeet` is unavailable or blocked, use the fallback publish flow only when the repository state is still safe: re-read `git diff` and `git status --porcelain`, stage explicit paths, commit, fetch, push with upstream tracking, then create a draft PR with a body file.

## Step 5: Wait for CI and Fix Until Green

Use the bundled read-only helper to summarize PR state:

```bash
python .agents/skills/finalize/scripts/fetch_pr_finalization_state.py > /tmp/finalize-pr-state.json
```

For an explicit PR:

```bash
python .agents/skills/finalize/scripts/fetch_pr_finalization_state.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-pr-state.json
```

Visible CI checks are green only when no check has bucket `fail`, `cancel`, or `pending`. Treat `skipping` as neutral. If a check provider is external and logs are unavailable, record the URL and status instead of guessing.

Wait for CI with GitHub CLI:

```bash
gh pr checks PR_NUMBER --watch --interval 10
gh pr checks PR_NUMBER --json name,state,bucket,link,workflow
```

If CI is pending, keep waiting and provide periodic status updates. If CI fails or is cancelled:

1. Count one CI loop cycle.
2. Load and use `github:gh-fix-ci` when available for log inspection.
3. Inspect failing check names, run URLs, and logs before editing.
4. Apply the smallest fix tied to the observed failure. The user's finalization request grants approval for clear CI fixes; ask only if the fix is broad, risky, unrelated, or ambiguous.
5. Run relevant local verification.
6. Commit and push the fix.
7. Return to CI wait.

Stop after 3 CI fix cycles in the same finalize run and report the failing checks, latest run URLs, local verification, and current commit.

## Step 6: Mark the PR Ready

Only after CI is green, convert the draft PR to ready for review:

```bash
gh pr ready PR_NUMBER
gh pr view PR_NUMBER --json isDraft,state,url
```

Do not mark ready while visible CI is failing, cancelled, or pending unless the user explicitly overrides the risk.

## Step 7: Wait for Copilot and Greptile

After the PR is ready, wait only for Copilot/Greptile signals that are actually detected on the PR. Do not invent missing Bot requirements.

Use the state helper repeatedly:

```bash
python .agents/skills/finalize/scripts/fetch_pr_finalization_state.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-pr-state.json
```

Detection sources include:

- Check name, workflow, or description containing `copilot` or `greptile`.
- Review author containing `copilot` or `greptile`.
- PR comment author containing `copilot` or `greptile`.

If a detected Bot check is pending, keep waiting. If a detected Bot check fails, or Bot comments/review threads appear, proceed to review handling. If neither Copilot nor Greptile appears on the PR, skip this wait and record that no Bot signal was detected.

If the helper returns `recommended_next_step: wait_for_bot_reviews`, stay in this step and keep waiting. A pending Greptile/Copilot check with zero review threads is still active work, not a reason to end the finalize turn.

## Step 8: Fetch and Address Review Threads

When review feedback exists, fetch thread-aware state plus REST numeric comment IDs:

```bash
python .agents/skills/finalize/scripts/fetch_review_threads.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-review-threads.json
```

Use this output to identify each target thread's:

- GraphQL `thread.id` for `resolveReviewThread`.
- `isResolved` and `isOutdated`.
- file/path/line context.
- REST numeric `comment_rest_id` to use with the REST reply endpoint.

Do not rely on flat PR comments as the source of truth for inline review-thread state.

Target unresolved, not-outdated, actionable threads. Skip already-resolved and outdated threads unless the user explicitly asks to handle them.

For actionable threads:

- Verify the review technically before editing.
- Implement clear fixes directly.
- Ask only when comments conflict, require product/architecture judgment, or exceed the branch scope.
- Run relevant local verification after fixes.
- Commit and push review fixes.
- Return to CI wait if new commits trigger checks.

Use at most 3 review-fix cycles in one finalize run. If unresolved actionable feedback remains after 3 cycles, stop and report the remaining threads.

If `fetch_review_threads.py` fails only because its initial auth check disagrees with otherwise working `gh api` access, fetch `reviewThreads` directly with `gh api graphql` instead of treating that as proof that GitHub is unreachable.

## Step 9: Reply Without Pending Review

After the relevant fix commit is pushed and CI has returned green, reply to each matching review comment using the REST pull request review-comment reply endpoint:

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

## Step 10: Resolve Threads

Resolve only after the matching REST reply succeeded:

```bash
gh api graphql \
  -F threadId=THREAD_NODE_ID \
  -f query='mutation($threadId: ID!) { resolveReviewThread(input: { threadId: $threadId }) { thread { id isResolved } } }'
```

Do not resolve a thread when:

- The reply failed.
- The pushed commit is missing or failed to push.
- CI is still failing for the fix commit.
- The thread is unrelated to the current changes.
- The reviewer comment is still technically unresolved.

If there are no matching review threads, state that no review replies or thread resolution were needed.

## Step 11: Confirm Final State

Re-run both helpers:

```bash
python .agents/skills/finalize/scripts/fetch_pr_finalization_state.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-pr-state-after.json
python .agents/skills/finalize/scripts/fetch_review_threads.py --repo OWNER/REPO --pr NUMBER > /tmp/finalize-review-threads-after.json
```

Confirm:

- PR is open and not draft.
- `recommended_next_step` is `complete`; otherwise return to the indicated step instead of producing a final report.
- Visible CI checks are green or explicitly caveated by the user.
- Detected Copilot/Greptile signals are complete or no signal was detected.
- Every target review thread has `isResolved: true`.
- `delivery.pr_ref` follow-up is committed when SDD archive needed the PR URL.
- The local worktree contains no unintended changes.

```bash
git status -sb
```

Final reports must include:

- Commit hash and message, or explain why no commit was needed.
- Push result and branch.
- PR number and URL, including whether it was newly created.
- SDD verify/archive result, or why it was skipped.
- Deslop summary.
- Verification commands and outcomes.
- CI final state.
- Copilot/Greptile wait result.
- Review threads replied to and resolved.
- Any threads, checks, or Bot signals skipped, blocked, or still unresolved.
