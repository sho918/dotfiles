#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
GIT_CO="$ROOT_DIR/.config/git/scripts/git-co"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

setup_tmpdir() {
  TMPDIR_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/git-co-test.XXXXXX")
  trap 'rm -rf "$TMPDIR_ROOT"' EXIT INT TERM HUP
}

setup_repo() {
  REPO_DIR=$TMPDIR_ROOT/repo
  mkdir -p "$REPO_DIR"

  git init -b main "$REPO_DIR" >/dev/null
  git -C "$REPO_DIR" config user.name 'Codex Test'
  git -C "$REPO_DIR" config user.email 'codex@example.com'
  git -C "$REPO_DIR" config commit.gpgsign false

  printf 'base\n' > "$REPO_DIR/file.txt"
  git -C "$REPO_DIR" add file.txt
  git -C "$REPO_DIR" commit -m 'init' >/dev/null

  git -C "$REPO_DIR" switch -c semantic-pr >/dev/null 2>&1
  git -C "$REPO_DIR" worktree add "$REPO_DIR/.worktrees/sdd-skill" main >/dev/null 2>&1
  REPO_PATH=$(CDPATH= cd -- "$REPO_DIR" && pwd -P)
}

setup_fake_fzf() {
  BIN_DIR=$TMPDIR_ROOT/bin
  mkdir -p "$BIN_DIR"

  cat > "$BIN_DIR/fzf" <<'EOF'
#!/bin/sh
set -eu
choice=${FZF_CHOICE:?}
awk -F '\t' -v choice="$choice" '
  $1 == choice {
    printf "\n%s\n", $0
    found = 1
    exit
  }
  END {
    if (!found) {
      exit 1
    }
  }
'
EOF
  chmod +x "$BIN_DIR/fzf"
}

assert_eq() {
  actual=$1
  expected=$2
  context=$3

  [ "$actual" = "$expected" ] || fail "$context: expected '$expected', got '$actual'"
}

run_git_co() {
  choice=$1

  set +e
  RUN_OUTPUT=$(
    cd "$REPO_DIR/.worktrees/sdd-skill" &&
      PATH="$BIN_DIR:$PATH" \
      FZF_CHOICE="$choice" \
      "$GIT_CO" 2>&1
  )
  RUN_STATUS=$?
  set -e
}

setup_remote() {
  ORIGIN_DIR=$TMPDIR_ROOT/origin.git
  HELPER_DIR=$TMPDIR_ROOT/helper

  git init --bare "$ORIGIN_DIR" >/dev/null 2>&1
  git -C "$REPO_DIR" remote add origin "$ORIGIN_DIR"
  git -C "$REPO_DIR" push -u origin semantic-pr >/dev/null 2>&1
  git -C "$REPO_DIR/.worktrees/sdd-skill" push -u origin main >/dev/null 2>&1

  git clone "$ORIGIN_DIR" "$HELPER_DIR" >/dev/null 2>&1
  git -C "$HELPER_DIR" config user.name 'Codex Test'
  git -C "$HELPER_DIR" config user.email 'codex@example.com'
  git -C "$HELPER_DIR" config commit.gpgsign false
  git -C "$HELPER_DIR" switch -c remote-only origin/main >/dev/null 2>&1
  git -C "$HELPER_DIR" push -u origin remote-only >/dev/null 2>&1
  git -C "$REPO_DIR/.worktrees/sdd-skill" fetch origin >/dev/null 2>&1
}

test_returns_repo_root_when_branch_is_checked_out_there() {
  run_git_co semantic-pr

  [ "$RUN_STATUS" -eq 0 ] || fail "git-co exited with $RUN_STATUS: $RUN_OUTPUT"
  assert_eq "$RUN_OUTPUT" "$REPO_PATH" "git-co should return repo root worktree path"
}

test_switches_local_branch_when_not_checked_out_elsewhere() {
  git -C "$REPO_DIR" branch docs-sync >/dev/null 2>&1

  run_git_co docs-sync

  [ "$RUN_STATUS" -eq 0 ] || fail "git-co exited with $RUN_STATUS: $RUN_OUTPUT"
  current_branch=$(git -C "$REPO_DIR/.worktrees/sdd-skill" branch --show-current)
  assert_eq "$current_branch" "docs-sync" "git-co should switch to a free local branch"
}

test_tracks_remote_only_branch() {
  setup_remote

  run_git_co remote-only

  [ "$RUN_STATUS" -eq 0 ] || fail "git-co exited with $RUN_STATUS: $RUN_OUTPUT"
  current_branch=$(git -C "$REPO_DIR/.worktrees/sdd-skill" branch --show-current)
  upstream=$(git -C "$REPO_DIR/.worktrees/sdd-skill" for-each-ref --format='%(upstream:short)' refs/heads/remote-only)
  assert_eq "$current_branch" "remote-only" "git-co should create and switch to the tracked branch"
  assert_eq "$upstream" "origin/remote-only" "git-co should preserve tracking for remote-only branches"
}

main() {
  setup_tmpdir
  setup_repo
  setup_fake_fzf
  test_returns_repo_root_when_branch_is_checked_out_there
  test_switches_local_branch_when_not_checked_out_elsewhere
  test_tracks_remote_only_branch
  printf 'ok\n'
}

main "$@"
