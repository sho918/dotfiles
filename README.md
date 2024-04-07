```bash
# Install Command Line Tools
xcode-select --install

# Install rosetta
sudo softwareupdate --install-rosetta

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew packages
brew bundle

# Change default shell to fish
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Install tmux plugin manager (Press `prefix + I` to install plugins)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher update

# Symlink
ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
ln -s (PWD)/.config/fish/conf.d/abbr.fish ~/.config/fish/conf.d/
ln -s (PWD)/.config/tmux/tmux.conf ~/.config/tmux/
ln -s (PWD)/.config/alacritty/alacritty.yml ~/.config/alacritty/
ln -s (PWD)/.config/git/config ~/.config/git/
ln -s (PWD)/.config/git/aliases ~/.config/git/
ln -s (PWD)/.config/git/allowed_signers ~/.config/git/
ln -s (PWD)/.config/git/hooks ~/.config/git/
ln -s (PWD)/.config/wezterm/wezterm.lua ~/.config/wezterm/
ln -s (PWD)/.ideavimrc ~/.ideavimrc

# Espanso
ln -s (PWD)/espanso/match/dev.yml (espanso path config)/match/

# Neovim
brew install neovim
ln -s (PWD)/.config/nvim/init.lua ~/.config/nvim/
ln -s (PWD)/.config/nvim/.stylua.toml ~/.config/nvim/
ln -s (PWD)/.config/nvim/.luarc.json ~/.config/nvim/
ln -s (PWD)/.config/nvim/lua ~/.config/nvim/lua
```
