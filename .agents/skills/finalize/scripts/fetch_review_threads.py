#!/usr/bin/env python3
"""Fetch PR review-thread state and REST review-comment IDs.

The script is intentionally read-only. It combines GitHub GraphQL reviewThreads
with REST pull review comments so the caller can reply through the REST
single-reply endpoint without creating a pending review.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from typing import Any
from urllib.parse import urlparse

QUERY = """\
query(
  $owner: String!,
  $repo: String!,
  $number: Int!,
  $threadsCursor: String
) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      number
      url
      title
      state
      author { login }
      headRefName
      baseRefName
      reviewThreads(first: 100, after: $threadsCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          diffSide
          startLine
          startDiffSide
          originalLine
          originalStartLine
          resolvedBy { login }
          comments(first: 100) {
            nodes {
              id
              body
              createdAt
              updatedAt
              author { login }
            }
          }
        }
      }
    }
  }
}
"""


def run(cmd: list[str], stdin: str | None = None) -> str:
    proc = subprocess.run(cmd, input=stdin, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}\n{proc.stderr.strip()}")
    return proc.stdout


def run_json(cmd: list[str], stdin: str | None = None) -> Any:
    output = run(cmd, stdin=stdin)
    try:
        return json.loads(output)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Failed to parse JSON from: {' '.join(cmd)}\n{output}") from exc


def ensure_gh_auth() -> None:
    try:
        run(["gh", "auth", "status"])
    except RuntimeError as exc:
        raise RuntimeError("gh auth status failed; authenticate with `gh auth login` first") from exc


def parse_repo(value: str) -> tuple[str, str]:
    if "/" not in value:
        raise ValueError("--repo must be OWNER/REPO")
    owner, repo = value.split("/", 1)
    if not owner or not repo:
        raise ValueError("--repo must be OWNER/REPO")
    return owner, repo


def parse_pr_url(value: str) -> tuple[str, str]:
    parsed = urlparse(value)
    parts = [part for part in parsed.path.split("/") if part]
    if len(parts) < 4 or parts[2] != "pull":
        raise ValueError(f"Unexpected PR URL shape: {value}")
    return parts[0], parts[1]


def resolve_current_pr() -> tuple[str, str, int]:
    pr = run_json(["gh", "pr", "view", "--json", "number,url"])
    owner, repo = parse_pr_url(pr["url"])
    return owner, repo, int(pr["number"])


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
    payload = run_json(cmd, stdin=QUERY)
    if payload.get("errors"):
        raise RuntimeError(json.dumps(payload["errors"], indent=2))
    return payload


def fetch_threads(owner: str, repo: str, number: int) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    cursor: str | None = None
    pull_request: dict[str, Any] | None = None
    threads: list[dict[str, Any]] = []

    while True:
        payload = graphql_page(owner, repo, number, cursor)
        pr = payload["data"]["repository"]["pullRequest"]
        if pull_request is None:
            pull_request = {
                "owner": owner,
                "repo": repo,
                "number": pr["number"],
                "url": pr["url"],
                "title": pr["title"],
                "state": pr["state"],
                "author": pr["author"]["login"] if pr.get("author") else None,
                "headRefName": pr["headRefName"],
                "baseRefName": pr["baseRefName"],
            }

        page = pr["reviewThreads"]
        threads.extend(page.get("nodes") or [])
        if not page["pageInfo"]["hasNextPage"]:
            break
        cursor = page["pageInfo"]["endCursor"]

    if pull_request is None:
        raise RuntimeError("PR was not returned by GitHub")
    return pull_request, threads


def fetch_rest_comments(owner: str, repo: str, number: int) -> list[dict[str, Any]]:
    path = f"repos/{owner}/{repo}/pulls/{number}/comments?per_page=100"
    try:
        pages = run_json(["gh", "api", "--paginate", "--slurp", path])
    except RuntimeError:
        comments = run_json(["gh", "api", path])
        if not isinstance(comments, list):
            raise RuntimeError("Unexpected REST comments response")
        return comments

    if not isinstance(pages, list):
        raise RuntimeError("Unexpected paginated REST comments response")

    comments: list[dict[str, Any]] = []
    for page in pages:
        if isinstance(page, list):
            comments.extend(page)
        else:
            raise RuntimeError("Unexpected REST comments page shape")
    return comments


def enrich_threads(
    threads: list[dict[str, Any]], rest_comments: list[dict[str, Any]]
) -> list[dict[str, Any]]:
    by_node_id = {comment.get("node_id"): comment for comment in rest_comments if comment.get("node_id")}
    enriched: list[dict[str, Any]] = []

    for thread in threads:
        comments = []
        for comment in thread["comments"]["nodes"]:
            rest = by_node_id.get(comment["id"])
            comments.append(
                {
                    "node_id": comment["id"],
                    "comment_rest_id": rest.get("id") if rest else None,
                    "author": comment["author"]["login"] if comment.get("author") else None,
                    "createdAt": comment["createdAt"],
                    "updatedAt": comment["updatedAt"],
                    "body": comment["body"],
                    "html_url": rest.get("html_url") if rest else None,
                    "in_reply_to_id": rest.get("in_reply_to_id") if rest else None,
                }
            )

        rest_ids = [comment["comment_rest_id"] for comment in comments if comment["comment_rest_id"]]
        enriched.append(
            {
                "id": thread["id"],
                "isResolved": thread["isResolved"],
                "isOutdated": thread["isOutdated"],
                "path": thread["path"],
                "line": thread["line"],
                "diffSide": thread["diffSide"],
                "startLine": thread["startLine"],
                "startDiffSide": thread["startDiffSide"],
                "originalLine": thread["originalLine"],
                "originalStartLine": thread["originalStartLine"],
                "resolvedBy": thread["resolvedBy"]["login"] if thread.get("resolvedBy") else None,
                "reply_comment_rest_id": rest_ids[-1] if rest_ids else None,
                "comments": comments,
            }
        )

    return enriched


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch GitHub PR review threads with REST numeric review-comment IDs."
    )
    parser.add_argument("--repo", help="Repository in OWNER/REPO form. Defaults to current branch PR.")
    parser.add_argument("--pr", type=int, help="Pull request number. Defaults to current branch PR.")
    args = parser.parse_args()

    try:
        ensure_gh_auth()
        if args.repo or args.pr:
            if not (args.repo and args.pr):
                raise ValueError("--repo and --pr must be provided together")
            owner, repo = parse_repo(args.repo)
            number = args.pr
        else:
            owner, repo, number = resolve_current_pr()

        pull_request, threads = fetch_threads(owner, repo, number)
        rest_comments = fetch_rest_comments(owner, repo, number)
        result = {
            "pull_request": pull_request,
            "review_threads": enrich_threads(threads, rest_comments),
        }
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
