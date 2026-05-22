#!/usr/bin/env python3
from __future__ import annotations

import argparse
import dataclasses
import json
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Sequence

SUCCESS_CONCLUSIONS = {"success", "neutral", "skipped"}
FAILURE_CONCLUSIONS = {
    "action_required",
    "cancelled",
    "failure",
    "startup_failure",
    "timed_out",
}

RUN_VIEW_FIELDS = (
    "attempt",
    "conclusion",
    "createdAt",
    "databaseId",
    "displayTitle",
    "event",
    "headBranch",
    "headSha",
    "jobs",
    "name",
    "number",
    "startedAt",
    "status",
    "updatedAt",
    "url",
    "workflowName",
)

RUN_LIST_FIELDS = (
    "attempt",
    "conclusion",
    "createdAt",
    "databaseId",
    "displayTitle",
    "event",
    "headBranch",
    "headSha",
    "name",
    "number",
    "startedAt",
    "status",
    "updatedAt",
    "url",
    "workflowName",
)

FAILURE_MARKERS = (
    "::error",
    "error:",
    "failed",
    "failure",
    "traceback",
    "exception",
    "assert",
    "panic",
    "fatal",
    "timeout",
    "timed out",
    "permission denied",
    "accessdenied",
    "resource not accessible",
)


@dataclasses.dataclass(frozen=True)
class RunRef:
    run_id: str
    github_repo: str | None = None
    attempt: int | None = None


@dataclasses.dataclass(frozen=True)
class GhResult:
    returncode: int
    stdout: str
    stderr: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Watch a GitHub Actions run and summarize failed logs.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument("--run", help="Workflow run URL or run database id.")
    target.add_argument("--workflow", help="Workflow name or workflow file to resolve.")
    parser.add_argument(
        "--repo",
        default=".",
        help="Path inside the local Git repository used as the gh working directory.",
    )
    parser.add_argument(
        "-R",
        "--github-repo",
        help="GitHub OWNER/REPO selector. URLs passed to --run set this automatically.",
    )
    parser.add_argument(
        "--branch",
        help="Branch used when resolving --workflow. Defaults to the current branch.",
    )
    parser.add_argument("--interval", type=int, default=15, help="Polling interval in seconds.")
    parser.add_argument("--timeout", type=int, default=1800, help="Overall timeout in seconds.")
    parser.add_argument(
        "--max-log-lines",
        type=int,
        default=160,
        help="Maximum failed-log snippet lines to include.",
    )
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = find_git_root(Path(args.repo))
    if repo_root is None:
        return fail("not inside a Git repository", as_json=args.json, code=2)

    if not ensure_gh_available(repo_root, args.json):
        return 2

    try:
        run_ref = resolve_run_ref(args, repo_root)
    except ValueError as error:
        return fail(str(error), as_json=args.json, code=2)

    timeout = max(0, args.timeout)
    interval = max(1, args.interval)
    max_log_lines = max(1, args.max_log_lines)
    deadline = time.monotonic() + timeout if timeout else None
    final_run: dict[str, Any] | None = None

    while True:
        run = fetch_run(run_ref, cwd=repo_root)
        if run is None:
            return fail("unable to fetch workflow run", as_json=args.json, code=2)

        final_run = run
        status = normalize(run.get("status"))
        conclusion = normalize(run.get("conclusion"))
        if not args.json:
            render_poll_status(run)

        if is_terminal(status, conclusion):
            break

        if deadline is not None and time.monotonic() >= deadline:
            summary = build_summary(
                run,
                run_ref=run_ref,
                timed_out=True,
                max_log_lines=max_log_lines,
                cwd=repo_root,
            )
            render_summary(summary, as_json=args.json)
            return 1

        time.sleep(interval)

    if final_run is None:
        return fail("workflow run did not resolve", as_json=args.json, code=2)

    summary = build_summary(
        final_run,
        run_ref=run_ref,
        timed_out=False,
        max_log_lines=max_log_lines,
        cwd=repo_root,
    )
    render_summary(summary, as_json=args.json)

    conclusion = normalize(final_run.get("conclusion"))
    return 0 if conclusion in SUCCESS_CONCLUSIONS else 1


def find_git_root(start: Path) -> Path | None:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=start,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return Path(result.stdout.strip())


def ensure_gh_available(cwd: Path, as_json: bool) -> bool:
    if shutil.which("gh") is None:
        fail("gh is not installed or not on PATH", as_json=as_json, code=2)
        return False
    result = run_gh(["auth", "status"], cwd=cwd)
    if result.returncode == 0:
        return True
    message = (result.stderr or result.stdout or "gh authentication failed").strip()
    fail(message, as_json=as_json, code=2)
    return False


def resolve_run_ref(args: argparse.Namespace, cwd: Path) -> RunRef:
    if args.run:
        run_ref = parse_run_reference(args.run)
        github_repo = args.github_repo or run_ref.github_repo
        return dataclasses.replace(run_ref, github_repo=github_repo)

    branch = args.branch or current_branch(cwd)
    github_repo = args.github_repo
    runs = fetch_workflow_runs(
        workflow=args.workflow,
        branch=branch,
        github_repo=github_repo,
        cwd=cwd,
    )
    if not runs:
        branch_note = f" on branch {branch}" if branch else ""
        raise ValueError(f"no workflow runs found for {args.workflow!r}{branch_note}")
    run_id = str(runs[0].get("databaseId") or "")
    if not run_id:
        raise ValueError("latest workflow run did not include databaseId")
    return RunRef(run_id=run_id, github_repo=github_repo)


def parse_run_reference(value: str) -> RunRef:
    raw = value.strip()
    if re.fullmatch(r"\d+", raw):
        return RunRef(run_id=raw)

    match = re.search(
        r"github\.com/(?P<owner>[^/\s]+)/(?P<repo>[^/\s]+)/actions/runs/(?P<run>\d+)"
        r"(?:/attempts/(?P<attempt>\d+))?",
        raw,
    )
    if not match:
        raise ValueError(
            "--run must be a GitHub Actions run URL or a numeric run database id"
        )
    attempt_raw = match.group("attempt")
    attempt = int(attempt_raw) if attempt_raw else None
    github_repo = f"{match.group('owner')}/{match.group('repo')}"
    return RunRef(run_id=match.group("run"), github_repo=github_repo, attempt=attempt)


def current_branch(cwd: Path) -> str | None:
    result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=cwd,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    branch = result.stdout.strip()
    return branch or None


def fetch_workflow_runs(
    workflow: str,
    branch: str | None,
    github_repo: str | None,
    cwd: Path,
) -> list[dict[str, Any]]:
    command = [
        "run",
        "list",
        "--workflow",
        workflow,
        "--limit",
        "1",
        "--all",
        "--json",
        ",".join(RUN_LIST_FIELDS),
    ]
    if branch:
        command.extend(["--branch", branch])
    command = with_repo_selector(command, github_repo)
    result = run_gh(command, cwd=cwd)
    if result.returncode != 0:
        message = (result.stderr or result.stdout or "gh run list failed").strip()
        raise ValueError(message)
    data = json.loads(result.stdout or "[]")
    if not isinstance(data, list):
        raise ValueError("unexpected gh run list JSON shape")
    return data


def fetch_run(run_ref: RunRef, cwd: Path) -> dict[str, Any] | None:
    command = [
        "run",
        "view",
        run_ref.run_id,
        "--json",
        ",".join(RUN_VIEW_FIELDS),
    ]
    if run_ref.attempt is not None:
        command.extend(["--attempt", str(run_ref.attempt)])
    command = with_repo_selector(command, run_ref.github_repo)
    result = run_gh(command, cwd=cwd)
    if result.returncode != 0:
        print((result.stderr or result.stdout).strip(), file=sys.stderr)
        return None
    data = json.loads(result.stdout or "{}")
    if not isinstance(data, dict):
        return None
    return data


def fetch_failed_log(run_ref: RunRef, cwd: Path) -> tuple[str, str | None]:
    command = ["run", "view", run_ref.run_id, "--log-failed"]
    if run_ref.attempt is not None:
        command.extend(["--attempt", str(run_ref.attempt)])
    command = with_repo_selector(command, run_ref.github_repo)
    result = run_gh(command, cwd=cwd)
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout, None

    fallback = ["run", "view", run_ref.run_id, "--log"]
    if run_ref.attempt is not None:
        fallback.extend(["--attempt", str(run_ref.attempt)])
    fallback = with_repo_selector(fallback, run_ref.github_repo)
    fallback_result = run_gh(fallback, cwd=cwd)
    if fallback_result.returncode == 0 and fallback_result.stdout.strip():
        note = (result.stderr or result.stdout or "").strip() or None
        return fallback_result.stdout, note

    message = "\n".join(
        part.strip()
        for part in [result.stderr, result.stdout, fallback_result.stderr, fallback_result.stdout]
        if part and part.strip()
    )
    return "", message or "failed logs were unavailable"


def run_gh(args: Sequence[str], cwd: Path) -> GhResult:
    process = subprocess.run(
        ["gh", *args],
        cwd=cwd,
        text=True,
        capture_output=True,
    )
    return GhResult(process.returncode, process.stdout, process.stderr)


def with_repo_selector(command: list[str], github_repo: str | None) -> list[str]:
    if not github_repo:
        return command
    return [*command, "-R", github_repo]


def is_terminal(status: str, conclusion: str) -> bool:
    return status == "completed" or bool(conclusion)


def build_summary(
    run: dict[str, Any],
    run_ref: RunRef,
    timed_out: bool,
    max_log_lines: int,
    cwd: Path,
) -> dict[str, Any]:
    conclusion = normalize(run.get("conclusion"))
    failed_jobs = collect_failed_jobs(run.get("jobs"))
    summary: dict[str, Any] = {
        "run_id": str(run.get("databaseId") or run_ref.run_id),
        "workflow": run.get("workflowName") or run.get("name"),
        "title": run.get("displayTitle"),
        "status": run.get("status"),
        "conclusion": run.get("conclusion"),
        "url": run.get("url"),
        "head_branch": run.get("headBranch"),
        "head_sha": run.get("headSha"),
        "attempt": run.get("attempt") or run_ref.attempt,
        "timed_out": timed_out,
        "failed_jobs": failed_jobs,
    }

    if timed_out:
        summary["classification"] = "unknown"
        summary["log_note"] = "watch timeout elapsed before the run reached a terminal state"
        return summary

    if conclusion in SUCCESS_CONCLUSIONS:
        summary["classification"] = "success"
        return summary

    log_text, log_error = fetch_failed_log(run_ref, cwd=cwd)
    snippet = extract_failure_snippet(log_text, max_lines=max_log_lines) if log_text else ""
    summary["classification"] = classify_failure(log_text, failed_jobs)
    summary["log_snippet"] = snippet
    if log_error:
        summary["log_note"] = log_error
    return summary


def collect_failed_jobs(jobs: Any) -> list[dict[str, Any]]:
    if not isinstance(jobs, list):
        return []
    failed = []
    for job in jobs:
        if not isinstance(job, dict):
            continue
        conclusion = normalize(job.get("conclusion"))
        status = normalize(job.get("status"))
        if conclusion in FAILURE_CONCLUSIONS or status in FAILURE_CONCLUSIONS:
            failed.append(
                {
                    "name": job.get("name"),
                    "conclusion": job.get("conclusion"),
                    "status": job.get("status"),
                    "databaseId": job.get("databaseId"),
                    "url": job.get("url"),
                }
            )
    return failed


def classify_failure(log_text: str, failed_jobs: list[dict[str, Any]]) -> str:
    text = " ".join(
        [
            log_text.lower(),
            " ".join(str(job.get("name") or "").lower() for job in failed_jobs),
        ]
    )
    if any(token in text for token in ("permission denied", "accessdenied", "403", "oidc")):
        return "permission"
    if any(token in text for token in ("resource not accessible", "secret", "secrets.")):
        return "permission"
    if any(token in text for token in ("workflow is not valid", "invalid workflow", "actionlint")):
        return "workflow"
    if any(token in text for token in ("eslint", "biome", "dprint", "lint failed")):
        return "lint"
    if any(token in text for token in ("typecheck", "tsc", "typescript")):
        return "typecheck"
    if any(token in text for token in ("test failed", "vitest", "jest", "pytest", "assert")):
        return "test"
    if any(token in text for token in ("npm err", "bun install", "lockfile", "pnpm install")):
        return "dependency"
    if any(token in text for token in ("build failed", "vite build", "next build")):
        return "build"
    if any(token in text for token in ("connection refused", "econnrefused", "docker", "service")):
        return "env"
    if any(token in text for token in ("timed out", "timeout", "flaky")):
        return "flaky"
    return "unknown"


def extract_failure_snippet(log_text: str, max_lines: int) -> str:
    lines = log_text.splitlines()
    if len(lines) <= max_lines:
        return "\n".join(lines)

    marker_indexes = [
        index
        for index, line in enumerate(lines)
        if any(marker in line.lower() for marker in FAILURE_MARKERS)
    ]
    if not marker_indexes:
        return "\n".join(lines[-max_lines:])

    selected: list[int] = []
    for index in marker_indexes:
        start = max(0, index - 6)
        end = min(len(lines), index + 10)
        selected.extend(range(start, end))
        if len(set(selected)) >= max_lines:
            break

    ordered = sorted(set(selected))[:max_lines]
    return "\n".join(lines[index] for index in ordered)


def render_poll_status(run: dict[str, Any]) -> None:
    status = run.get("status") or "unknown"
    conclusion = run.get("conclusion") or "pending"
    workflow = run.get("workflowName") or run.get("name") or "workflow"
    url = run.get("url") or ""
    print(f"{workflow}: status={status} conclusion={conclusion} {url}".rstrip())


def render_summary(summary: dict[str, Any], as_json: bool) -> None:
    if as_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return

    print()
    print(f"Run: {summary.get('workflow') or summary.get('run_id')}")
    print(f"Status: {summary.get('status')} / {summary.get('conclusion')}")
    if summary.get("url"):
        print(f"URL: {summary['url']}")
    if summary.get("head_branch") or summary.get("head_sha"):
        print(f"Head: {summary.get('head_branch') or '-'} @ {summary.get('head_sha') or '-'}")
    print(f"Classification: {summary.get('classification')}")

    failed_jobs = summary.get("failed_jobs") or []
    if failed_jobs:
        print("Failed jobs:")
        for job in failed_jobs:
            print(f"- {job.get('name')}: {job.get('status')} / {job.get('conclusion')}")

    if summary.get("log_note"):
        print(f"Log note: {summary['log_note']}")
    if summary.get("log_snippet"):
        print()
        print("Failure log snippet:")
        print(summary["log_snippet"])


def fail(message: str, as_json: bool, code: int) -> int:
    if as_json:
        print(json.dumps({"error": message, "exit_code": code}, ensure_ascii=False))
    else:
        print(f"Error: {message}", file=sys.stderr)
    return code


def normalize(value: Any) -> str:
    return str(value or "").strip().lower()


if __name__ == "__main__":
    raise SystemExit(main())
