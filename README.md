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
$ ln -s (PWD)/.tmux.conf ~/.tmux.conf
$ ln -s (PWD)/.alacritty.yml ~/.alacritty.yml
$ ln -s (PWD)/.gitconfig.aliases ~/.gitconfig.aliases
$ ln -s (PWD)/.gnupg/gpg-agent.conf ~/.gnupg/
$ ln -s (PWD)/.gnupg/gpg.conf ~/.gnupg/

# Git
$ git config --global include.path ~/.gitconfig.aliases

# Git
$ git config --local user.name "<name>"
$ git config --local user.email <email>
$ git config --local commit.gpgsign true
$ git config --global include.path ~/.gitconfig.aliases
```
