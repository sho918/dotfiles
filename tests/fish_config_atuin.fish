set -l repo_root (path dirname (path dirname (status filename)))
set -gx HOME (mktemp -d)
set -gx XDG_CONFIG_HOME "$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME/fish"

set -gx TEST_FZF_LOG (mktemp)
set -gx TEST_ATUIN_LOG (mktemp)

function fail
    echo $argv >&2
    exit 1
end

function brew
    if test "$argv[1]" = "--prefix"
        echo /opt/homebrew
        return 0
    end

    return 1
end

function fzf_configure_bindings
    printf '%s\n' $argv >"$TEST_FZF_LOG"
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

function atuin
    printf '%s\n' $argv >"$TEST_ATUIN_LOG"

    if test "$argv[1]" = "init"; and test "$argv[2]" = "fish"
        echo 'function _atuin_stub; end'
        return 0
    end

    return 1
end

function tty
    echo /dev/ttys000
end

source "$repo_root/.config/fish/config.fish"

set -l fzf_args (string collect <"$TEST_FZF_LOG")
test -n "$fzf_args"; or fail "fzf_configure_bindings was not called"

if string match -q '*--history=*' -- "$fzf_args"
    fail "fzf_configure_bindings still owns history binding: $fzf_args"
end

set -l atuin_first (sed -n '1p' "$TEST_ATUIN_LOG")
set -l atuin_second (sed -n '2p' "$TEST_ATUIN_LOG")
if test "$atuin_first" != "init"; or test "$atuin_second" != "fish"
    fail "atuin init fish was not called"
end
