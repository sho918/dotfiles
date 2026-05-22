#!/usr/bin/env python3
from __future__ import annotations

import unittest

from watch_actions_run import (
    classify_failure,
    extract_failure_snippet,
    parse_run_reference,
)


class ParseRunReferenceTest(unittest.TestCase):
    def test_numeric_run_id(self) -> None:
        run_ref = parse_run_reference("1234567890")

        self.assertEqual(run_ref.run_id, "1234567890")
        self.assertIsNone(run_ref.github_repo)
        self.assertIsNone(run_ref.attempt)

    def test_github_actions_run_url(self) -> None:
        run_ref = parse_run_reference(
            "https://github.com/hokan-inc/ms-bosyu-analyze/actions/runs/24064081327"
        )

        self.assertEqual(run_ref.run_id, "24064081327")
        self.assertEqual(run_ref.github_repo, "hokan-inc/ms-bosyu-analyze")
        self.assertIsNone(run_ref.attempt)

    def test_github_actions_attempt_url(self) -> None:
        run_ref = parse_run_reference(
            "https://github.com/sho918/dotfiles/actions/runs/123/attempts/2"
        )

        self.assertEqual(run_ref.run_id, "123")
        self.assertEqual(run_ref.github_repo, "sho918/dotfiles")
        self.assertEqual(run_ref.attempt, 2)

    def test_rejects_non_run_input(self) -> None:
        with self.assertRaises(ValueError):
            parse_run_reference("https://github.com/sho918/dotfiles/actions")


class LogHelpersTest(unittest.TestCase):
    def test_extract_failure_snippet_prefers_error_context(self) -> None:
        log = "\n".join([f"line {index}" for index in range(40)])
        log = log.replace("line 25", "line 25 ERROR: build failed")

        snippet = extract_failure_snippet(log, max_lines=8)

        self.assertIn("ERROR: build failed", snippet)
        self.assertLessEqual(len(snippet.splitlines()), 8)

    def test_classifies_permission_failures(self) -> None:
        result = classify_failure("AccessDenied: not authorized", [])

        self.assertEqual(result, "permission")

    def test_classifies_typecheck_from_job_name(self) -> None:
        result = classify_failure("", [{"name": "web typecheck"}])

        self.assertEqual(result, "typecheck")


if __name__ == "__main__":
    unittest.main()
