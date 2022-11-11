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

# Install fisher
$ curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
$ fisher update

# Symlink
$ ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
$ ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
$ ln -s (PWD)/.config/fish/conf.d/abbr.fish ~/.config/fish/conf.d/
$ ln -s (PWD)/.tmux.conf ~/.tmux.conf
$ ln -s (PWD)/.alacritty.yml ~/.alacritty.yml
$ ln -s (PWD)/.vimrc ~/.vimrc
$ ln -s (PWD)/.ideavimrc ~/.ideavimrc

# Espanso
$ ln -s (PWD)/espanso/match/dev.yml (espanso path config)/match/

# Git
$ ln -s (PWD)/.gitconfig ~/.gitconfig
$ ln -s (PWD)/.gitconfig.aliases ~/.gitconfig.aliases

# GPG
$ gpg --import --allow-secret-key-import <KEY>
$ ln -s (PWD)/.gnupg/gpg-agent.conf ~/.gnupg/
$ ln -s (PWD)/.gnupg/gpg.conf ~/.gnupg/
```
