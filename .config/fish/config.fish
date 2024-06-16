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
# ASDF
#
source (brew --prefix asdf)/libexec/asdf.fish

#
# FZF
#
fzf_configure_bindings --directory=\ct --git_log= --git_status= --history=\cr --processes= --variables=
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
