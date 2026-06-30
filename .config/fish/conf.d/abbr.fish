# https://fishshell.com/docs/current/cmds/abbr.html
abbr -a -g cd z
abbr -a -g ls eza
abbr -a -g ll eza -l
abbr -a -g la eza -a
abbr -a -g cat bat
abbr -a -g grep rg
abbr -a -g find fd
abbr -a -g dig doggo

abbr -a -g v nvim
abbr -a -g vim nvim
abbr -a -g pp pnpm
abbr -a -g c zed
abbr -a -g ga git add -A
abbr -a -g avl aws-vault login

function __abbr_cc_escape_toml_string --argument-names value
    set -l escaped (string replace -a "\\" "\\\\" -- "$value")
    string replace -a '"' '\"' -- "$escaped"
end

function __abbr_cc
    set -l prompt (string join " " \
        "Use the git-commit skill to create commits in English." \
        "Continue until the Worktree is clean." \
        "Ensure that commits are separated into meaningful units." \
        "Never bypass git commit signing: do not use --no-gpg-sign, commit.gpgsign=false, git config commit.gpgsign false, git config --unset commit.gpgsign, or GIT_CONFIG_* injection to disable commit.gpgsign." \
        "If signing fails, report the gpg/SSH agent socket cause without disabling signing." \
        "If any git commit command fails, stop and print the exact commit message planned for the failed commit, plus the matching git commit command when practical, so the user can retry manually after fixing the cause.")
    set -l cmd codex exec

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l writable_roots
        set -l git_dir (command git rev-parse --path-format=absolute --git-dir 2>/dev/null)
        set -l common_dir (command git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

        for dir in $git_dir $common_dir
            if test -n "$dir"; and not contains -- "$dir" $writable_roots
                set -a writable_roots "$dir"
            end
        end

        set -l filesystem_entries '"/"="read"' '":tmpdir"="write"' '":slash_tmp"="write"' '":project_roots"={ "."="write" }'

        for dir in $writable_roots
            set -l escaped_dir (__abbr_cc_escape_toml_string "$dir")
            set -a filesystem_entries "\"$escaped_dir\"=\"write\""
        end

        set -l filesystem_config (string join "" "permissions.cc_commit.filesystem={" (string join ", " $filesystem_entries) "}")
        set -a cmd --config 'default_permissions="cc_commit"' --config "$filesystem_config"
    else
        set -a cmd --sandbox workspace-write
    end

    set -a cmd -m gpt-5.3-codex-spark --config 'model_reasoning_effort="low"' "$prompt"
    string join -- " " (string escape -- $cmd)
end

abbr -a -g cc --function __abbr_cc
