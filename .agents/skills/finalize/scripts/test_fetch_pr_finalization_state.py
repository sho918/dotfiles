#!/usr/bin/env python3

from __future__ import annotations

import sys
import unittest
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_PATH = SCRIPT_DIR.parent / "SKILL.md"
sys.path.insert(0, str(SCRIPT_DIR))

import fetch_pr_finalization_state as finalization_state  # noqa: E402
from fetch_pr_finalization_state import (  # noqa: E402
    build_state,
    classify_checks,
    detect_bot_signals,
    summarize_next_step,
)


class FinalizationStateTest(unittest.TestCase):
    def test_classify_checks_prioritizes_failures_over_pending(self) -> None:
        checks = [
            {"name": "Lint", "bucket": "pass", "state": "SUCCESS"},
            {"name": "Typecheck", "bucket": "pending", "state": "IN_PROGRESS"},
            {"name": "Tests", "bucket": "fail", "state": "FAILURE"},
            {"name": "Optional", "bucket": "skipping", "state": "SKIPPED"},
        ]

        summary = classify_checks(checks)

        self.assertEqual(summary["overall"], "fail")
        self.assertEqual(summary["counts"]["fail"], 1)
        self.assertEqual([check["name"] for check in summary["failing"]], ["Tests"])
        self.assertEqual([check["name"] for check in summary["pending"]], ["Typecheck"])

    def test_classify_checks_treats_skipping_as_neutral(self) -> None:
        checks = [
            {"name": "Lint", "bucket": "pass", "state": "SUCCESS"},
            {"name": "Docs only", "bucket": "skipping", "state": "SKIPPED"},
        ]

        summary = classify_checks(checks)

        self.assertEqual(summary["overall"], "pass")
        self.assertEqual(summary["counts"]["skipping"], 1)

    def test_detect_bot_signals_from_checks_reviews_and_comments(self) -> None:
        checks = [
            {"name": "Greptile Review", "bucket": "pending", "workflow": "review"},
            {"name": "Copilot for Pull Requests", "bucket": "pass", "workflow": "review"},
        ]
        reviews = [{"author": {"login": "github-copilot[bot]"}, "state": "COMMENTED"}]
        comments = [{"author": {"login": "greptile-app[bot]"}, "body": "P2: simplify this"}]

        signals = detect_bot_signals(checks=checks, reviews=reviews, comments=comments)

        self.assertTrue(signals["copilot"]["detected"])
        self.assertEqual(signals["copilot"]["status"], "complete")
        self.assertIn("check:Copilot for Pull Requests", signals["copilot"]["sources"])
        self.assertTrue(signals["greptile"]["detected"])
        self.assertEqual(signals["greptile"]["status"], "pending")
        self.assertIn("comment:greptile-app[bot]", signals["greptile"]["sources"])

    def test_summarize_next_step_priority(self) -> None:
        bot_signals = {
            "copilot": {"detected": True, "status": "complete", "sources": []},
            "greptile": {"detected": True, "status": "pending", "sources": []},
        }

        self.assertEqual(
            summarize_next_step(
                pull_request={"isDraft": True},
                checks_summary={"overall": "fail"},
                bot_signals=bot_signals,
                review_summary={"unresolved_threads": 1},
            ),
            "fix_ci",
        )
        self.assertEqual(
            summarize_next_step(
                pull_request={"isDraft": True},
                checks_summary={"overall": "pass"},
                bot_signals=bot_signals,
                review_summary={"unresolved_threads": 1},
            ),
            "mark_ready",
        )
        self.assertEqual(
            summarize_next_step(
                pull_request={"isDraft": False},
                checks_summary={"overall": "pass"},
                bot_signals=bot_signals,
                review_summary={"unresolved_threads": 1},
            ),
            "wait_for_bot_reviews",
        )

    def test_greptile_in_progress_waits_even_without_threads(self) -> None:
        checks = [
            {
                "name": "Greptile Review",
                "bucket": "pending",
                "state": "IN_PROGRESS",
                "workflow": "review",
            }
        ]
        bot_signals = detect_bot_signals(checks=checks, reviews=[], comments=[])

        self.assertEqual(
            summarize_next_step(
                pull_request={"isDraft": False},
                checks_summary=classify_checks(
                    [{"name": "CI", "bucket": "pass", "state": "SUCCESS"}]
                ),
                bot_signals=bot_signals,
                review_summary={"unresolved_threads": 0},
            ),
            "wait_for_bot_reviews",
        )

    def test_copilot_review_request_waits_even_without_threads(self) -> None:
        state = self._build_state_with_pr(
            {
                "reviewRequests": [
                    {
                        "requestedReviewer": {
                            "login": "copilot",
                        },
                    }
                ],
            }
        )

        self.assertTrue(state["bot_signals"]["copilot"]["detected"])
        self.assertEqual(state["bot_signals"]["copilot"]["status"], "pending")
        self.assertEqual(state["recommended_next_step"], "wait_for_bot_reviews")

    def test_copilot_status_check_rollup_in_progress_waits(self) -> None:
        state = self._build_state_with_pr(
            {
                "statusCheckRollup": [
                    {
                        "name": "Copilot code review",
                        "state": "IN_PROGRESS",
                        "workflowName": "review",
                    }
                ],
            }
        )

        self.assertTrue(state["bot_signals"]["copilot"]["detected"])
        self.assertEqual(state["bot_signals"]["copilot"]["status"], "pending")
        self.assertIn(
            "statusCheckRollup:Copilot code review",
            state["bot_signals"]["copilot"]["sources"],
        )
        self.assertEqual(state["recommended_next_step"], "wait_for_bot_reviews")

    def test_skill_forbids_final_report_while_remote_checks_are_active(self) -> None:
        skill_text = SKILL_PATH.read_text()

        for required_text in (
            "Active Remote Wait Gate",
            "wait_for_ci",
            "wait_for_bot_reviews",
            "IN_PROGRESS",
            "NOT_DONE",
        ):
            with self.subTest(required_text=required_text):
                self.assertIn(required_text, skill_text)

    def test_skill_creates_branch_for_detached_head_without_asking(self) -> None:
        skill_text = SKILL_PATH.read_text()

        for required_text in (
            "detached HEAD",
            "git switch -c",
            "without asking",
        ):
            with self.subTest(required_text=required_text):
                self.assertIn(required_text, skill_text)

    def _build_state_with_pr(self, extra_pr_fields: dict) -> dict:
        original_fetch_pr = finalization_state.fetch_pr
        original_fetch_checks = finalization_state.fetch_checks
        original_fetch_review_summary = finalization_state.fetch_review_summary

        def fake_fetch_pr(repo: str | None, pr: str | None) -> dict:
            return {
                "number": 12,
                "url": "https://github.com/owner/repo/pull/12",
                "title": "Test PR",
                "state": "OPEN",
                "isDraft": False,
                "headRefName": "feature",
                "baseRefName": "main",
                "reviewDecision": None,
                "reviews": [],
                "comments": [],
                **extra_pr_fields,
            }

        def fake_fetch_checks(repo: str | None, pr: str | None) -> list[dict]:
            return [{"name": "CI", "bucket": "pass", "state": "SUCCESS"}]

        def fake_fetch_review_summary(owner: str, repo: str, number: int) -> dict:
            return {
                "total_threads": 0,
                "unresolved_threads": 0,
                "unresolved_threads_including_outdated": 0,
            }

        try:
            finalization_state.fetch_pr = fake_fetch_pr
            finalization_state.fetch_checks = fake_fetch_checks
            finalization_state.fetch_review_summary = fake_fetch_review_summary
            return build_state("owner/repo", "12")
        finally:
            finalization_state.fetch_pr = original_fetch_pr
            finalization_state.fetch_checks = original_fetch_checks
            finalization_state.fetch_review_summary = original_fetch_review_summary


if __name__ == "__main__":
    unittest.main()
