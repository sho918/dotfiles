#!/bin/zsh
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)

output=$(fish --no-config -c '
set -gx HOME (mktemp -d)
set -gx XDG_CONFIG_HOME "$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME/fish"

function brew
    if test "$argv[1]" = "--prefix"
        echo /opt/homebrew
        return 0
    end

    return 1
end

function fzf_configure_bindings
end

function zoxide
    if test "$argv[1]" = "init"; and test "$argv[2]" = "fish"
        echo true
        return 0
    end

    return 1
end

function direnv
    if test "$argv[1]" = "hook"; and test "$argv[2]" = "fish"
        echo true
        return 0
    end

    return 1
end

function tty
    echo /dev/ttys000
end

source "'"$repo_root"'/.config/fish/config.fish"
' 2>&1 || true)

if [[ "$output" == *"Unknown command: atuin"* ]]; then
    echo "config.fish tried to run atuin before it was installed" >&2
    exit 1
fi
