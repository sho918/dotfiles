#
# Homebrew
#
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

# Configuring Completions in fish
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
if test -d (brew --prefix)"/share/fish/completions"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
end
if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

#
# ASDF
#
source (brew --prefix asdf)/asdf.fish

#
# FZF
#
fzf_configure_bindings --directory=\ct --history=\cr --git_log=\ck --git_status=\cs --variables --processes

#
# iTerm2 
# (https://iterm2.com/documentation-shell-integration.html)
#
source {$HOME}/.iterm2_shell_integration.fish

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
