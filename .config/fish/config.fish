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
# Television
#
if type -q tv
    tv init fish | source

    function tv_shell_history
        set -l current_prompt (commandline -cp)

        # Move to the next line so the prompt is not overwritten by tv.
        printf "\n"

        set -l output (
            tv fish-history \
                --input "$current_prompt" \
                --inline \
                --no-status-bar \
                --show-preview \
                --preview-word-wrap
        )

        if test -n "$output"
            commandline -r "$output"
        end

        printf "\033[A"
        commandline -f repaint
    end

    function tv_ghq_cd
        if not type -q ghq
            commandline -f repaint
            return 1
        end

        set -l root (ghq root)
        set -l preview_command "eza --all --color=always $root/{}"
        if not type -q eza
            set preview_command "ls -la $root/{}"
        end

        set -l selected (
            tv \
                --source-command "ghq list" \
                --source-output "{}" \
                --preview-command "$preview_command" \
                --input-header "ghq" \
                --input-prompt "repo> " \
                --inline \
                --no-status-bar
        )

        if test -n "$selected"
            cd -- "$root/$selected"
        end

        commandline -f repaint
    end

    for mode in default insert
        bind --mode $mode ctrl-g tv_ghq_cd
    end
end

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
