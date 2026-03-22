#!/bin/zsh

set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

function_state=$(fish --no-config -c 'source .config/fish/config.fish; functions -q tv_ghq_cd; and echo defined; or echo missing')
if [[ "$function_state" != "defined" ]]; then
  echo "expected tv_ghq_cd to be defined, got: $function_state"
  exit 1
fi

bind_output=$(fish --no-config -c 'source .config/fish/config.fish; bind \cg' 2>&1)
if [[ "$bind_output" != *"tv_ghq_cd"* ]]; then
  echo "expected ctrl-g to bind tv_ghq_cd"
  echo "$bind_output"
  exit 1
fi
