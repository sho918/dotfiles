#! /usr/bin/env node

import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import os from "node:os";
import path from "node:path";

try {
  const input = JSON.parse(readFileSync(process.stdin.fd, "utf8"));
  if (!input.transcript_path) {
    process.exit(0);
  }

  const homeDir = os.homedir();
  let transcriptPath = input.transcript_path;

  if (transcriptPath.startsWith("~/")) {
    transcriptPath = path.join(homeDir, transcriptPath.slice(2));
  }

  const allowedBase = path.join(homeDir, ".claude", "projects") + path.sep;
  const resolvedPath = realpathSync(path.resolve(transcriptPath));

  if (!resolvedPath.startsWith(allowedBase)) {
    process.exit(1);
  }

  if (!existsSync(resolvedPath)) {
    console.log("Hook execution failed: Transcript file does not exist");
    process.exit(0);
  }

  const lines = readFileSync(resolvedPath, "utf-8")
    .split("\n")
    .filter((line) => line.trim());
  if (lines.length === 0) {
    console.log("Hook execution failed: Transcript file is empty");
    process.exit(0);
  }

  const lastLine = lines[lines.length - 1];
  const transcript = JSON.parse(lastLine);
  const lastMessageContent = transcript?.message?.content?.[0]?.text;

  if (lastMessageContent) {
    // AppleScript のワンライナー通知
    execFileSync(
      "osascript",
      [
        "-e",
        `display notification ${JSON.stringify(
          lastMessageContent
        )} with title "Claude Code"`,
      ],
      { stdio: "ignore" }
    );
  }
} catch (error) {
  console.log("Hook execution failed:", error.message);
  process.exit(1);
}
