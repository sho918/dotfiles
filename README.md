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
mkdir -p ~/.config/{fish,tmux,alacritty,git,wezterm,navi,zed,yazi,mise,lazygit,sketchybar}
mkdir -p ~/.config/fish/{completions,conf.d}
ln -s (PWD)/.config/fish/config.fish ~/.config/fish/
ln -s (PWD)/.config/fish/fish_plugins ~/.config/fish/
ln -s (PWD)/.config/fish/conf.d/abbr.fish ~/.config/fish/conf.d/
ln -s (PWD)/.config/fish/completions/aws-vault.fish ~/.config/fish/completions/
ln -s (PWD)/.config/fish/completions/container-use.fish ~/.config/fish/completions/
ln -s (PWD)/.config/git/config ~/.config/git/
ln -s (PWD)/.config/git/aliases ~/.config/git/
ln -s (PWD)/.config/git/allowed_signers ~/.config/git/
ln -s (PWD)/.config/git/scripts ~/.config/git/
ln -s (PWD)/.config/git/hooks ~/.config/git/
ln -s (PWD)/.config/wezterm/wezterm.lua ~/.config/wezterm/
ln -s (PWD)/.config/wezterm/balance.lua ~/.config/wezterm/
ln -s (PWD)/.config/wezterm/keybinds.lua ~/.config/wezterm/
ln -s (PWD)/.config/navi/config.yaml ~/.config/navi/
ln -s (PWD)/.config/navi/cheats ~/.config/navi/cheats
ln -s (PWD)/.config/yazi/flavors ~/.config/yazi/flavors
ln -s (PWD)/.config/yazi/theme.toml ~/.config/yazi/
ln -s (PWD)/.config/mise/config.toml ~/.config/mise/
ln -s (PWD)/.config/lazygit/config.yml ~/.config/lazygit/
ln -s (PWD)/.config/nvim ~/.config/
ln -s (PWD)/.config/sketchybar ~/.config/
ln -s (PWD)/.config/stylua.toml ~/.config/stylua.toml
ln -s (PWD)/.bashrc ~/.bashrc
ln -s (PWD)/.ideavimrc ~/.ideavimrc
ln -s (PWD)/.tool-versions ~/.tool-versions

# Espanso
ln -s (PWD)/espanso/match/dev.yml (espanso path config)/match/
ln -s (PWD)/espanso/config/default.yml (espanso path config)/config/

# Mise
mise install

# gh
gh extension install dlvhdr/gh-dash

# Claude Code
mkdir -p ~/.claude
ln -s (PWD)/.claude/CLAUDE.md ~/.claude/
ln -s (PWD)/.claude/settings.json ~/.claude/
ln -s (PWD)/.claude/permissive-open.sb ~/.claude/
ln -s (PWD)/.claude/hooks ~/.claude/hooks

# Codex
mkdir -p ~/.codex
ln -s (PWD)/.codex/config.toml ~/.codex/

#
# Agent Skills
#
npx skills add https://github.com/vercel-labs/skills --skill find-skills

# git
npx skills add https://github.com/github/awesome-copilot --skill gh-cli
npx skills add https://github.com/github/awesome-copilot --skill git-commit

# frontend design
npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines
npx skills add https://github.com/anthropics/skills --skill frontend-design
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max

# react
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-composition-patterns

# database
npx skills add https://github.com/supabase/agent-skills --skill supabase-postgres-best-practices

# Add https://github.com/obra/superpowers
```
