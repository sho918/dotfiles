# Dotfiles

```bash
# Install Command Line Tools
$ xcode-select --install

# Install homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install
$ brew bundle

# Symlink
$ ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
$ ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
$ ln -s (PWD)/.tmux.conf ~/.tmux.conf
$ ln -s (PWD)/.alacritty.yml ~/.alacritty.yml

# Install fish plugins
$ fisher update
```
