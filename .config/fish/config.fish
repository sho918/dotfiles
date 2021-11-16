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
# Direnv
#
eval (direnv hook fish)

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
alias lzd "lazydocker"

alias t  "tmux attach || tmux"
alias tl "tmux list-sessions"

alias b  "bundle"
alias bx "bundle exec"
alias r  "bin/rails"
alias rc "bin/rails console"
alias rd "bin/dev"

alias proco "bundle exec procodile start --dev"

alias gp  "git pull --prune"
alias gb  "git branch"
alias gba "git branch -a"
alias gc  "git commit"
alias gca "git commit -a"
alias gd  "git diff --color | diff-so-fancy"
alias gst "git status -sb"
alias gl  "git log --pretty=format:'%C(red)%h%Creset %C(green)%cd%Creset %s %C(yellow)[%an] <%ae>%Creset %C(cyan)%d%Creset' --abbrev-commit --date=format-local:'%Y-%m-%d %H:%M'"
alias glm "git log --pretty=format:'%C(red)%h%Creset %C(green)%cd%Creset %s %C(yellow)[%an] <%ae>%Creset %C(cyan)%d%Creset' --abbrev-commit --date=format-local:'%Y-%m-%d %H:%M' --no-merges"
alias grb "git branch --merged | egrep -v '(^\*|master|main)' | xargs git branch -d"
alias gsw "git switch -"
