#!/usr/bin/env python3
"""Fetch PR finalization state for the finalize skill.

The script is read-only. It summarizes PR draft state, visible checks,
Copilot/Greptile signals, and unresolved review-thread counts so the skill can
choose the next finalization step without hand-parsing several gh commands.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from typing import Any
from urllib.parse import urlparse

CHECK_FIELDS = "name,state,bucket,link,workflow,description,startedAt,completedAt,event"
PR_FIELDS = "number,url,title,state,isDraft,headRefName,baseRefName,reviewDecision,reviews,comments"

THREAD_QUERY = """\
query(
  $owner: String!,
  $repo: String!,
  $number: Int!,
  $threadsCursor: String
) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $threadsCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
        }
      }
    }
  }
}
"""

BOT_ALIASES = {
    "copilot": ("copilot", "github-copilot"),
    "greptile": ("greptile",),
}

NEUTRAL_BUCKETS = {"pass", "skipping"}
FAILING_BUCKETS = {"fail", "cancel"}
PENDING_BUCKETS = {"pending"}


def run(cmd: list[str], stdin: str | None = None, allow_exit_codes: tuple[int, ...] = (0,)) -> str:
    proc = subprocess.run(cmd, input=stdin, capture_output=True, text=True)
    if proc.returncode not in allow_exit_codes:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\n{proc.stderr.strip()}")
    return proc.stdout


def run_json(cmd: list[str], stdin: str | None = None, allow_exit_codes: tuple[int, ...] = (0,)) -> Any:
    output = run(cmd, stdin=stdin, allow_exit_codes=allow_exit_codes)
    if not output.strip():
        return None
    try:
        return json.loads(output)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Failed to parse JSON from: {' '.join(cmd)}\n{output}") from exc


def parse_repo_from_url(value: str) -> tuple[str, str]:
    parsed = urlparse(value)
    parts = [part for part in parsed.path.split("/") if part]
    if len(parts) < 2:
        raise ValueError(f"Unexpected GitHub URL shape: {value}")
    return parts[0], parts[1]


def parse_repo(value: str) -> tuple[str, str]:
    if "/" not in value:
        raise ValueError("--repo must be OWNER/REPO")
    owner, repo = value.split("/", 1)
    if not owner or not repo:
        raise ValueError("--repo must be OWNER/REPO")
    return owner, repo


def normalize_bucket(value: Any) -> str:
    bucket = str(value or "").lower()
    if bucket in FAILING_BUCKETS | PENDING_BUCKETS | NEUTRAL_BUCKETS:
        return bucket
    return "unknown"


def classify_checks(checks: list[dict[str, Any]]) -> dict[str, Any]:
    counts = {bucket: 0 for bucket in ("pass", "fail", "pending", "skipping", "cancel", "unknown")}
    normalized_checks: list[dict[str, Any]] = []

    for check in checks:
        bucket = normalize_bucket(check.get("bucket"))
        counts[bucket] += 1
        normalized = dict(check)
        normalized["bucket"] = bucket
        normalized_checks.append(normalized)

    failing = [check for check in normalized_checks if check["bucket"] in FAILING_BUCKETS]
    pending = [check for check in normalized_checks if check["bucket"] in PENDING_BUCKETS]
    unknown = [check for check in normalized_checks if check["bucket"] == "unknown"]

    if failing:
        overall = "fail"
    elif pending:
        overall = "pending"
    elif unknown:
        overall = "unknown"
    else:
        overall = "pass"

    return {
        "overall": overall,
        "counts": counts,
        "failing": failing,
        "pending": pending,
        "unknown": unknown,
        "total": len(normalized_checks),
    }


def text_matches_bot(value: Any, aliases: tuple[str, ...]) -> bool:
    text = str(value or "").lower()
    return any(alias in text for alias in aliases)


def merge_bot_status(current: str, candidate: str) -> str:
    rank = {"not_found": 0, "complete": 1, "pending": 2, "failed": 3}
    return candidate if rank[candidate] > rank[current] else current


def check_bot_status(check: dict[str, Any]) -> str:
    bucket = normalize_bucket(check.get("bucket"))
    if bucket in FAILING_BUCKETS:
        return "failed"
    if bucket in PENDING_BUCKETS:
        return "pending"
    return "complete"


def detect_bot_signals(
    *,
    checks: list[dict[str, Any]],
    reviews: list[dict[str, Any]],
    comments: list[dict[str, Any]],
) -> dict[str, dict[str, Any]]:
    signals = {
        name: {"detected": False, "status": "not_found", "sources": []}
        for name in BOT_ALIASES
    }

    for bot, aliases in BOT_ALIASES.items():
        for check in checks:
            if any(
                text_matches_bot(check.get(field), aliases)
                for field in ("name", "workflow", "description")
            ):
                signals[bot]["detected"] = True
                signals[bot]["status"] = merge_bot_status(signals[bot]["status"], check_bot_status(check))
                signals[bot]["sources"].append(f"check:{check.get('name') or '<unnamed>'}")

        for review in reviews:
            author = (review.get("author") or {}).get("login")
            if text_matches_bot(author, aliases):
                signals[bot]["detected"] = True
                signals[bot]["status"] = merge_bot_status(signals[bot]["status"], "complete")
                signals[bot]["sources"].append(f"review:{author}")

        for comment in comments:
            author = (comment.get("author") or {}).get("login")
            if text_matches_bot(author, aliases):
                signals[bot]["detected"] = True
                signals[bot]["status"] = merge_bot_status(signals[bot]["status"], "complete")
                signals[bot]["sources"].append(f"comment:{author}")

    return signals


def summarize_next_step(
    *,
    pull_request: dict[str, Any],
    checks_summary: dict[str, Any],
    bot_signals: dict[str, dict[str, Any]],
    review_summary: dict[str, Any],
) -> str:
    checks_overall = checks_summary.get("overall")
    if checks_overall == "fail":
        return "fix_ci"
    if checks_overall == "pending":
        return "wait_for_ci"
    if checks_overall == "unknown":
        return "inspect_ci"
    if pull_request.get("isDraft"):
        return "mark_ready"

    detected_signals = [signal for signal in bot_signals.values() if signal.get("detected")]
    if any(signal.get("status") == "failed" for signal in detected_signals):
        return "address_bot_review"
    if any(signal.get("status") == "pending" for signal in detected_signals):
        return "wait_for_bot_reviews"
    if int(review_summary.get("unresolved_threads") or 0) > 0:
        return "address_review_threads"
    return "complete"


def fetch_pr(repo: str | None, pr: str | None) -> dict[str, Any]:
    cmd = ["gh", "pr", "view"]
    if pr:
        cmd.append(pr)
    cmd += ["--json", PR_FIELDS]
    if repo:
        cmd += ["--repo", repo]
    data = run_json(cmd)
    if not isinstance(data, dict):
        raise RuntimeError("Unexpected PR response")
    return data


def fetch_checks(repo: str | None, pr: str | None) -> list[dict[str, Any]]:
    cmd = ["gh", "pr", "checks"]
    if pr:
        cmd.append(pr)
    cmd += ["--json", CHECK_FIELDS]
    if repo:
        cmd += ["--repo", repo]
    data = run_json(cmd, allow_exit_codes=(0, 1, 8))
    if data is None:
        return []
    if not isinstance(data, list):
        raise RuntimeError("Unexpected checks response")
    return data


def graphql_page(owner: str, repo: str, number: int, cursor: str | None = None) -> dict[str, Any]:
    cmd = [
        "gh",
        "api",
        "graphql",
        "-F",
        "query=@-",
        "-F",
        f"owner={owner}",
        "-F",
        f"repo={repo}",
        "-F",
        f"number={number}",
    ]
    if cursor:
        cmd += ["-F", f"threadsCursor={cursor}"]
    payload = run_json(cmd, stdin=THREAD_QUERY)
    if payload.get("errors"):
        raise RuntimeError(json.dumps(payload["errors"], indent=2))
    return payload


def fetch_review_summary(owner: str, repo: str, number: int) -> dict[str, Any]:
    cursor: str | None = None
    total = 0
    unresolved = 0
    unresolved_not_outdated = 0

    while True:
        payload = graphql_page(owner, repo, number, cursor)
        pr = payload["data"]["repository"]["pullRequest"]
        page = pr["reviewThreads"]
        threads = page.get("nodes") or []
        total += len(threads)
        for thread in threads:
            if not thread.get("isResolved"):
                unresolved += 1
                if not thread.get("isOutdated"):
                    unresolved_not_outdated += 1
        if not page["pageInfo"]["hasNextPage"]:
            break
        cursor = page["pageInfo"]["endCursor"]

    return {
        "total_threads": total,
        "unresolved_threads": unresolved_not_outdated,
        "unresolved_threads_including_outdated": unresolved,
    }


def build_state(repo: str | None, pr: str | None) -> dict[str, Any]:
    pull_request = fetch_pr(repo, pr)
    owner, repo_name = parse_repo(repo) if repo else parse_repo_from_url(pull_request["url"])
    checks = fetch_checks(repo, str(pull_request["number"]))
    checks_summary = classify_checks(checks)
    bot_signals = detect_bot_signals(
        checks=checks,
        reviews=pull_request.get("reviews") or [],
        comments=pull_request.get("comments") or [],
    )
    review_summary = fetch_review_summary(owner, repo_name, int(pull_request["number"]))

    return {
        "pull_request": {
            "owner": owner,
            "repo": repo_name,
            "number": pull_request["number"],
            "url": pull_request["url"],
            "title": pull_request["title"],
            "state": pull_request["state"],
            "isDraft": pull_request["isDraft"],
            "headRefName": pull_request["headRefName"],
            "baseRefName": pull_request["baseRefName"],
            "reviewDecision": pull_request.get("reviewDecision"),
        },
        "checks_summary": checks_summary,
        "bot_signals": bot_signals,
        "review_summary": review_summary,
        "recommended_next_step": summarize_next_step(
            pull_request=pull_request,
            checks_summary=checks_summary,
            bot_signals=bot_signals,
            review_summary=review_summary,
        ),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch PR finalization state.")
    parser.add_argument("--repo", help="Repository in OWNER/REPO form. Defaults to current branch PR.")
    parser.add_argument("--pr", help="Pull request number, URL, or branch. Defaults to current branch PR.")
    args = parser.parse_args()

    try:
        state = build_state(args.repo, args.pr)
        print(json.dumps(state, indent=2, ensure_ascii=False))
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
