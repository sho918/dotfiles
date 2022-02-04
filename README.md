# Dotfiles

```bash
# Install Command Line Tools
$ xcode-select --install

# Install homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew packages
$ brew bundle

# Change shell
$ echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
$ chsh -s /opt/homebrew/bin/fish

# Install tmux plugin manager
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Symlink
$ ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
$ ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
$ ln -s (PWD)/.tmux.conf ~/.tmux.conf
$ ln -s (PWD)/.alacritty.yml ~/.alacritty.yml
$ ln -s (PWD)/.gitconfig.aliases ~/.gitconfig.aliases
$ ln -s (PWD)/.gnupg/gpg-agent.conf ~/.gnupg/
$ ln -s (PWD)/.gnupg/gpg.conf ~/.gnupg/

# Git
$ git config --global trim.bases develop,master
$ git config --global include.path ~/.gitconfig.aliases

# Install fish plugins
$ fisher update
```
