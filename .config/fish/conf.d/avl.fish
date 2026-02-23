function avl --description "aws-vault login with fzf profile picker"
    if test (count $argv) -gt 0
        set -l escaped_args (string escape --style=script -- $argv)
        set -l expanded_cmd "aws-vault login "(string join " " -- $escaped_args)

        command aws-vault login $argv
        set -l login_status $status

        if status is-interactive
            builtin history append -- $expanded_cmd
        end

        return $login_status
    end

    if not command -q aws-vault
        echo "avl: aws-vault is not installed" >&2
        return 127
    end

    if not command -q fzf
        echo "avl: fzf is not installed" >&2
        return 127
    end

    set -l profiles (command aws-vault list --profiles)
    set -l list_status $status
    if test $list_status -ne 0
        echo "avl: failed to list aws-vault profiles" >&2
        return $list_status
    end

    if test (count $profiles) -eq 0
        echo "avl: no aws-vault profiles found" >&2
        return 1
    end

    set -l profile (printf '%s\n' $profiles | command fzf --prompt='AWS Profile> ')
    set -l fzf_status $status
    if test $fzf_status -ne 0
        return $fzf_status
    end

    if test -z "$profile"
        return 1
    end

    set -l escaped_profile (string escape --style=script -- $profile)
    set -l expanded_cmd "aws-vault login $escaped_profile"

    command aws-vault login "$profile"
    set -l login_status $status

    if status is-interactive
        builtin history append -- $expanded_cmd
    end

    return $login_status
end
