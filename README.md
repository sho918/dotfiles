```bash
# Apple
defaults write -g ApplePressAndHoldEnabled -bool false

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
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher update

# Symlink
mkdir -p ~/.config/{fish,tmux,alacritty,git,wezterm,navi,zed,nvim,yazi}
mkdir -p ~/.config/fish/conf.d
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
ln -s (PWD)/.config/wezterm/keybinds.lua ~/.config/wezterm/
ln -s (PWD)/.config/navi/config.yaml ~/.config/navi/
ln -s (PWD)/.config/navi/cheats ~/.config/navi/cheats
ln -s (PWD)/.config/zed/settings.json ~/.config/zed/
ln -s (PWD)/.config/zed/keymap.json ~/.config/zed/
ln -s (PWD)/.config/yazi/flavors ~/.config/yazi/flavors
ln -s (PWD)/.config/yazi/theme.toml ~/.config/yazi/
ln -s (PWD)/.config/stylua.toml ~/.config/stylua.toml
ln -s (PWD)/.ideavimrc ~/.ideavimrc
ln -s (PWD)/.tool-versions ~/.tool-versions

# Neovim
# https://github.com/sho918/lazyvim-starter/
git clone git@github.com:sho918/lazyvim-starter.git ~/.config/nvim

# Espanso
ln -s (PWD)/espanso/match/dev.yml (espanso path config)/match/
ln -s (PWD)/espanso/config/default.yml (espanso path config)/config/

# AWSume
pipx install awsume
pipx inject awsume setuptools
awsume-configure

# asdf
brew install gpg
asdf plugin-add python https://github.com/asdf-community/asdf-python.git
asdf plugin-add poetry https://github.com/asdf-community/asdf-poetry.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add yarn https://github.com/twuni/asdf-yarn.git
asdf plugin-add pnpm https://github.com/jonathanmorley/asdf-pnpm.git
asdf plugin-add bun https://github.com/cometkim/asdf-bun.git
asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf plugin add ecspresso https://github.com/kayac/asdf-ecspresso.git
asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
asdf plugin add uv https://github.com/b1-luettje/asdf-uv.git
```
