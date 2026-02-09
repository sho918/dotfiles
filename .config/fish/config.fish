#
# Homebrew
#
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

# Linux Brew
if test -d "/home/linuxbrew/.linuxbrew"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# Configuring Completions in fish
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
if test -d (brew --prefix)"/share/fish/completions"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
end
if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

#
# Home
#
set -x XDG_CONFIG_HOME "$HOME/.config"

#
# FZF
#
fzf_configure_bindings --directory=\ct --git_log= --git_status= --history=\cr --processes= --variables=
set fzf_preview_dir_cmd eza --all --color=always
set fzf_fd_opts --hidden --max-depth 5
set -x GHQ_SELECTOR fzf-tmux

#
# Zoxide
#
zoxide init fish | source

#
# Direnv
#
direnv hook fish | source

#
# Jetbrains
#
fish_add_path $HOME/bin

#
# GPG
#
set -x GPG_TTY `tty`

#
# Pipx
#
fish_add_path $HOME/.local/bin

#
# Rye
#
fish_add_path $HOME/.rye/shims

#
# mysql-client
#
set -x PKG_CONFIG_PATH (brew --prefix)/opt/mysql-client/lib/pkgconfig

#
# yazi
#
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

#
# git-wt
#
git wt --init fish | source

if functions -q git
    if functions -q __git_wt_git
        functions -e __git_wt_git
    end
    functions -c git __git_wt_git

    function git --wraps git
        if test "$argv[1]" = "co"
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

        __git_wt_git $argv
    end
end
