if set -q __dotfiles_git_wt_loaded
    return
end
set -g __dotfiles_git_wt_loaded 1

git wt --init fish | source

if functions -q git
    if functions -q __git_wt_git
        functions -e __git_wt_git
    end
    functions -c git __git_wt_git

    function __git_cd_on_directory_result
        set -l result (__git_wt_git $argv)
        set -l exit_code $status

        if test $exit_code -eq 0 -a (count $result) -gt 0
            set -l last_line $result[-1]
            if test -d "$last_line"
                for line in $result[1..-2]
                    printf "%s\n" "$line"
                end
                cd "$last_line"
                return 0
            end
        end

        for line in $result
            printf "%s\n" "$line"
        end
        return $exit_code
    end

    function git --wraps git
        switch "$argv[1]"
            case co main master
                __git_cd_on_directory_result $argv
                return $status
        end

        __git_wt_git $argv
    end
end
