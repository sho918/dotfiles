#
# Homebrew
#
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

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
fzf_configure_bindings --directory=\ct --git_status=\cs

#
# Settings
#
set -x GPG_TTY `tty`

#
# Alias
#
alias dcu "docker compose up"

alias t  "tmux attach || tmux"
alias tl "tmux list-sessions"
