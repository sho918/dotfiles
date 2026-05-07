if set -q __dotfiles_git_ws_loaded
    return
end
set -g __dotfiles_git_ws_loaded 1

if command -q git-ws
    command git ws init-shell fish | source

    if functions -q __git_ws_run_and_cd
        function git --wraps git
            switch "$argv[1]"
                case ws co cow main master
                    __git_ws_run_and_cd $argv
                    return $status
            end

            command git $argv
        end
    end
end
