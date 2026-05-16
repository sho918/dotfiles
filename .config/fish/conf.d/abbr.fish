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

function __abbr_cc
    set -l prompt "Use the git-commit skill to create commits in English. Continue until the Worktree is clean. Ensure that commits are separated into meaningful units."
    set -l cmd codex exec --sandbox workspace-write

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l add_dirs
        set -l git_dir (command git rev-parse --path-format=absolute --git-dir 2>/dev/null)
        set -l common_dir (command git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

        for dir in $git_dir $common_dir
            if test -n "$dir"; and not contains -- "$dir" $add_dirs
                set -a add_dirs "$dir"
            end
        end

        for dir in $add_dirs
            set -a cmd --add-dir "$dir"
        end
    end

    set -a cmd -m gpt-5.3-codex-spark --config 'model_reasoning_effort="low"' "$prompt"
    string join -- " " (string escape -- $cmd)
end

abbr -a -g cc --function __abbr_cc
