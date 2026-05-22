#!/usr/bin/env python3

from __future__ import annotations

import sys
import unittest
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from fetch_pr_finalization_state import (  # noqa: E402
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


if __name__ == "__main__":
    unittest.main()
