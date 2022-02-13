```bash
# Install Command Line Tools
$ xcode-select --install

# Install brew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew packages
$ brew bundle

# Change shell
$ echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
$ chsh -s /opt/homebrew/bin/fish

# Install tmux plugin manager (Press `prefix + I` to install plugins)
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install iterm2 shell integration
$ curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash

# Install fisher
$ curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
$ fisher update

# Symlink
$ ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
$ ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
$ ln -s (PWD)/.tmux.conf ~/.tmux.conf

# Add iterm2 color schemes
$ ghq get git@github.com:mbadolato/iTerm2-Color-Schemes.git
$ tools/import-scheme.sh schemes/*

# Git
$ ln -s (PWD)/.gitconfig ~/.gitconfig
$ ln -s (PWD)/.gitconfig.aliases ~/.gitconfig.aliases

# GPG
$ gpg --import --allow-secret-key-import <KEY>
$ ln -s (PWD)/.gnupg/gpg-agent.conf ~/.gnupg/
$ ln -s (PWD)/.gnupg/gpg.conf ~/.gnupg/

# SpaceVim
$ curl -sLf https://spacevim.org/install.sh | bash
$ ln -s (PWD)/.SpaceVim.d/init.toml ~/.SpaceVim.d/
```
