---
name: gh-watch-actions
description: Use when a user asks to monitor, investigate, or fix a specific GitHub Actions workflow run, run URL, run id, or named workflow; also use for rerun loops after applying a CI fix.
---

# GH Watch Actions

## Overview

Monitor one GitHub Actions run, inspect failed logs when it reaches a terminal failure, make only evidence-backed fixes, then recheck the replacement run when a push triggers one.

This skill is run-centric. If the user asks about generic PR checks without naming a run or workflow, use `github:gh-fix-ci` first.

## Progress Checklist

Copy this checklist and keep it updated:

```markdown
GH Watch Actions:
- [ ] Resolve the repo, branch, and target run
- [ ] Watch until success, failure, cancellation, or timeout
- [ ] Inspect failed jobs and logs
- [ ] Classify the root cause
- [ ] Apply the smallest safe fix when the cause is repo-local
- [ ] Run targeted local verification
- [ ] Commit/push when needed to trigger the replacement run
- [ ] Watch the replacement run or report the remaining blocker
```

## Workflow

1. Confirm the local repo state before watching:
   ```bash
   git status --short --branch
   git branch --show-current
   gh auth status
   ```
   If `gh` fails because of sandbox auth/network isolation but the user's host session is expected to work, rerun the `gh` command in the host/escalated context before asking the user to re-authenticate.

2. Resolve the target:
   - Prefer a user-provided GitHub Actions run URL or numeric run id.
   - For a workflow name or file, resolve the latest run on the current branch unless the user gave `--branch`.
   - Do not monitor unrelated repository-wide historical failures by default.

3. Watch with the bundled helper:
   ```bash
   python .agents/skills/gh-watch-actions/scripts/watch_actions_run.py --run "<url-or-id>" --repo "."
   ```
   For a workflow name:
   ```bash
   python .agents/skills/gh-watch-actions/scripts/watch_actions_run.py --workflow "<name-or-file>" --repo "."
   ```
   Defaults: 15 second polling, 30 minute timeout, and 160 failed-log lines.

4. If the run succeeds, report the run URL and exit. If it fails, inspect the helper output and fetch more detail when needed:
   ```bash
   gh run view <run-id> --json attempt,conclusion,jobs,status,url,workflowName
   gh run view <run-id> --log-failed
   ```
   Use `gh run download` or the Actions artifacts API only when logs point to artifact-only stderr/stdout. Do not guess when logs are missing.

5. Classify the failure before editing:
   - `test`, `lint`, `typecheck`, `build`: usually repo-local and fixable.
   - `workflow`: inspect `.github/workflows/*` syntax, permissions, event filters, and shell snippets.
   - `dependency`: inspect lockfiles, install flags, package manager versions, and caches.
   - `env` or `permission`: separate repo config bugs from missing secrets, IAM, OIDC, or external service access.
   - `flaky`: prove flakiness with rerun evidence before changing retry/timeouts.
   - `external` or `unknown`: report evidence and stop unless the user asks to continue.

6. Apply fixes only when tied to the observed logs:
   - Make the smallest change that explains the failed job.
   - Stay inside the current branch scope.
   - Stop and ask before touching secrets, IAM, production config, broad architecture, unrelated failures, or ambiguous product behavior.
   - Do not use a passing rerun to hide a real bug unless the logs support a transient external failure.

7. Verify locally after edits:
   - Run the focused command matching the failed job.
   - Always run `git diff --check`.
   - Do not claim a fix is complete when verification is skipped, blocked, timed out, or still failing.

8. Push and rewatch when remote CI needs a new commit:
   - Do not commit from `main`, `master`, or detached HEAD unless the user explicitly requested it.
   - Keep unrelated dirty files out of staging.
   - Commit with a concise Conventional Commit message.
   - Push the current branch, then resolve the new run for the pushed SHA or workflow and return to the watch step.
   - Stop after 3 fix/watch cycles for the same failure class and report the latest evidence.

## Helper Script

`scripts/watch_actions_run.py` exits with:

| Exit | Meaning |
| --- | --- |
| `0` | Target run reached a success-like conclusion |
| `1` | Target run failed, was cancelled, timed out, or the watch timed out |
| `2` | Input, local repo, `gh`, auth, or run-resolution error |

Useful options:

```bash
python .agents/skills/gh-watch-actions/scripts/watch_actions_run.py \
  --run "https://github.com/OWNER/REPO/actions/runs/123" \
  --repo "." \
  --interval 15 \
  --timeout 1800 \
  --json
```

The helper intentionally does not edit files, rerun workflows, commit, or push. It only resolves runs, polls status, fetches failed logs, and prints a compact classification.

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Watching latest repo failures instead of the requested run | Resolve the specific URL/id or latest run for the named workflow and branch |
| Treating missing logs as proof of cause | Say logs are unavailable and fetch job/artifact detail before editing |
| Fixing permissions by changing app code | Separate repo-local config bugs from secrets/IAM/OIDC issues |
| Claiming green after local tests only | Watch the replacement GitHub Actions run when the request is remote CI |
| Letting one failing job mask another | Recheck all failed jobs after each pushed fix |
