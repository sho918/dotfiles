#!/bin/zsh

set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

if rg -q 'decors/fish-ghq' .config/fish/fish_plugins; then
  echo "expected decors/fish-ghq to be removed from fish_plugins"
  exit 1
fi

if rg -q 'GHQ_SELECTOR' .config/fish/config.fish; then
  echo "expected GHQ_SELECTOR to be removed from config.fish"
  exit 1
fi
