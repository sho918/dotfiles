# Neovim Config

## Overview

- Leader: `<Space>`
- Plugin manager: `lazy.nvim`
- Tabline: theme toggle button is disabled

## Formatting

- Formatter selection is project-aware (see `lua/plugins/conform.lua`).
- JS/TS: Biome > oxfmt > oxlint > ESLint > Prettier (first available).
- JSON: dprint > Biome > Prettier (first available).
- HTML/CSS/Markdown/YAML/TOML: dprint > Prettier (first available).
- Python: isort + black when configured; otherwise ruff format if only ruff is configured.
- Biome/dprint/oxfmt/oxlint/eslint/prettierd run only when a config is present (`biome.json*`, `dprint.json*`, `.oxfmtrc.json*`, `.oxlintrc*`, `oxlint.config.*`, `.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `prettier.config.*`, or `package.json` with `eslintConfig` / `oxlint` / `prettier`).
- `prettier` runs as a final fallback even without a config.
- Python lint: ruff > flake8 (first available by config).
- JS/TS lint: eslint_d when ESLint config is present.

## Keybindings

### Custom overrides (`lua/mappings.lua`)

| Category     | Keys                | Description                            |
| ------------ | ------------------- | -------------------------------------- |
| Basic        | `;`                 | Command line                           |
| Movement     | Insert `<C-p>`      | Move up                                |
| Movement     | Insert `<C-n>`      | Move down                              |
| Movement     | Insert `<C-b>`      | Move left                              |
| Movement     | Insert `<C-f>`      | Move right                             |
| Oil          | Normal `<C-n>`      | Oil: Move down                         |
| Oil          | Normal `<C-p>`      | Oil: Move up                           |
| Save/Quit    | `<leader>ww`        | Save                                   |
| Save/Quit    | `<leader>q`         | Quit                                   |
| Split        | `<leader>-`         | Horizontal split                       |
| Split        | `<leader>\`         | Vertical split                         |
| Window       | `<C-h>`             | Move left window (smart-splits)        |
| Window       | `<C-j>`             | Move down window (smart-splits)        |
| Window       | `<C-k>`             | Move up window (smart-splits)          |
| Window       | `<C-l>`             | Move right window (smart-splits)       |
| Line Move    | Visual `<C-j>`      | Move selection down                    |
| Line Move    | Visual `<C-k>`      | Move selection up                      |
| Git          | `<leader>gg`        | LazyGit                                |
| Git          | `<leader>gl`        | LazyGit log                            |
| Git          | `<leader>gf`        | LazyGit current file                   |
| Git          | `<leader>gd`        | Diffview worktree                      |
| Git          | `<leader>gD`        | Diffview previous commit               |
| Git          | `<leader>gs`        | Diffview staged                        |
| Git          | `<leader>gh`        | File history                           |
| Git          | `<leader>gH`        | Branch history                         |
| Git          | `<leader>gm`        | Diffview main                          |
| Git          | `<leader>gM`        | Diffview master                        |
| Git          | `<leader>gr`        | PR review menu                         |
| Git          | Visual `<leader>gr` | PR suggest change                      |
| Git          | `<leader>gq`        | Diffview close                         |
| Git          | `<leader>gt`        | Diffview file panel                    |
| Git          | `<leader>gp`        | Preview hunk                           |
| Git          | `<leader>hr`        | Reset hunk                             |
| Git          | `<leader>hs`        | Stage hunk                             |
| Git          | `<leader>hu`        | Undo stage hunk                        |
| Git          | `<leader>gb`        | Blame line                             |
| Git          | `<leader>ga`        | Blame column                           |
| Git          | `]c`                | Next hunk                              |
| Git          | `[c`                | Previous hunk                          |
| Search       | `<leader><leader>`  | Smart Find                             |
| Search       | `<leader>ff`        | Files                                  |
| Search       | `<leader>fg`        | Git files                              |
| Search       | `<leader>fw`        | Grep                                   |
| Search       | `<leader>fb`        | Buffers                                |
| Search       | `<leader>fr`        | Recent files                           |
| Search       | `<leader>fh`        | Help pages                             |
| Search       | `<leader>fo`        | Recent files                           |
| Search       | `<leader>fl`        | Buffer lines                           |
| Search       | `<leader>fz`        | Grep buffers                           |
| Search       | `<leader>ma`        | Marks                                  |
| Search       | `<leader>fa`        | Find all (hidden, ignored)             |
| Oil          | `<leader>e`         | Oil float toggle                       |
| Flash        | `s`                 | Flash jump                             |
| Flash        | `S`                 | Flash treesitter                       |
| Flash        | `r`                 | Flash remote                           |
| Flash        | `R`                 | Flash treesitter search                |
| Flash        | `:<C-s>`            | Flash search toggle                    |
| Lasterisk    | `*`                 | Search word (no jump)                  |
| Lasterisk    | `g*`                | Search word (partial)                  |
| Lasterisk    | Visual `g*`         | Search selection (partial)             |
| Folds        | `zR`                | Open all folds (UFO)                   |
| Folds        | `zM`                | Close all folds (UFO)                  |
| Precognition | `<leader>up`        | Toggle Precognition                    |
| Trouble      | `<leader>xx`        | Diagnostics                            |
| Trouble      | `<leader>xX`        | Buffer diagnostics                     |
| Trouble      | `<leader>cs`        | Symbols                                |
| Trouble      | `<leader>cl`        | LSP references and definitions (right) |
| Trouble      | `<leader>xL`        | Location list                          |
| Trouble      | `<leader>xQ`        | Quickfix list                          |
| LSP          | `gd`                | Definition                             |
| LSP          | `gD`                | Declaration                            |
| LSP          | `gI`                | Implementation                         |
| LSP          | `gy`                | Type definition                        |
| LSP          | `gR`                | References                             |
| LSP          | `<leader>ca`        | Code Action                            |
| LSP          | `<leader>o`         | Code Action                            |
| LSP          | `<leader>r`         | Rename (IncRename)                     |
| LSP          | `<leader>ld`        | Line diagnostics                       |
| LSP          | `[d`                | Previous diagnostic                    |
| LSP          | `]d`                | Next diagnostic                        |
| LSP          | `<leader>ls`        | Document symbols                       |
| LSP          | `<leader>lS`        | Workspace symbols                      |
| LSP          | `K`                 | Hover                                  |
| LSP          | `gh`                | Hover                                  |
| Treesitter   | `af` / `if`         | Function outer/inner                   |
| Treesitter   | `ac` / `ic`         | Class outer/inner                      |
| Treesitter   | `aa` / `ia`         | Parameter outer/inner                  |
| Overlook     | `<leader>pd`        | Peek definition                        |
| Overlook     | `<leader>pp`        | Peek cursor                            |
| Overlook     | `<leader>pu`        | Restore popup                          |
| Overlook     | `<leader>pU`        | Restore all popups                     |
| Overlook     | `<leader>pc`        | Close all popups                       |
| Overlook     | `<leader>pf`        | Switch focus                           |
| Overlook     | `<leader>ps`        | Open in split                          |
| Overlook     | `<leader>pv`        | Open in vsplit                         |
| Substitute   | `gr`                | Replace operator                       |
| Substitute   | `grr`               | Replace line                           |
| Substitute   | Visual `gr`         | Replace selection                      |
| CopilotChat  | `<leader>ag`        | Chat                                   |
| Claude Code  | `<leader>ac`        | Toggle Claude Code                     |
| Claude Code  | `<leader>af`        | Focus Claude Code                      |
| Claude Code  | `<leader>ar`        | Resume Claude Code                     |
| Claude Code  | `<leader>aC`        | Continue Claude Code                   |
| Claude Code  | `<leader>am`        | Select Claude model                    |
| Claude Code  | `<leader>ab`        | Add current buffer                     |
| Claude Code  | `<leader>aB`        | Add file from tree                     |
| Claude Code  | Visual `<leader>as` | Send selection                         |
| Claude Code  | `<leader>aa`        | Accept diff                            |
| Claude Code  | `<leader>ad`        | Deny diff                              |

### NvChad defaults (active in this config)

| Category  | Keys         | Description                  |
| --------- | ------------ | ---------------------------- |
| Basic     | `<Esc>`      | Clear search highlight       |
| Basic     | `<C-s>`      | Save                         |
| Basic     | `<C-c>`      | Copy all                     |
| Display   | `<leader>n`  | Toggle line numbers          |
| Display   | `<leader>rn` | Toggle relative numbers      |
| UI        | `<leader>ch` | Cheatsheet                   |
| LSP       | `<leader>fm` | Format                       |
| LSP       | `<leader>ds` | Diagnostic loclist           |
| Comment   | `<leader>/`  | Toggle comment               |
| Terminal  | `<leader>h`  | New terminal (horizontal)    |
| Terminal  | `<leader>v`  | New terminal (vertical)      |
| Terminal  | `<A-h>`      | Toggle terminal (horizontal) |
| Terminal  | `<A-v>`      | Toggle terminal (vertical)   |
| Terminal  | `<A-i>`      | Toggle terminal (float)      |
| Terminal  | `<C-x>`      | Exit terminal mode           |
| WhichKey  | `<leader>wK` | WhichKey list                |
| WhichKey  | `<leader>wk` | WhichKey query               |
| Theme     | `<leader>th` | Theme picker                 |
| Tabufline | `<leader>b`  | New buffer                   |
| Tabufline | `<tab>`      | Next buffer                  |
| Tabufline | `<S-tab>`    | Previous buffer              |
| Tabufline | `<leader>x`  | Close buffer                 |

## Plugins

**Base**

- `NvChad/NvChad`
- `folke/lazy.nvim`

**Completion/AI**

- `saghen/blink.cmp`, `fang2hou/blink-copilot`
- `zbirenbaum/copilot.lua`, `CopilotC-Nvim/CopilotChat.nvim`
- `coder/claudecode.nvim`

**LSP/Format/Lint**

- `neovim/nvim-lspconfig`
- `ray-x/lsp_signature.nvim`
- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`

**Python/Venv**

- `linux-cultist/venv-selector.nvim`

**Search/File**

- `folke/snacks.nvim`
- `stevearc/oil.nvim`

**Git**

- `lewis6991/gitsigns.nvim`
- `sindrets/diffview.nvim`
- `kdheepak/lazygit.nvim`
- `Yu-Leo/blame-column.nvim`
- `otavioschwanck/github-pr-reviewer.nvim`

**UI/Editing**

- `folke/noice.nvim`, `rcarriga/nvim-notify`, `MunifTanjim/nui.nvim`
- `folke/trouble.nvim`
- `folke/flash.nvim`
- `rapan931/lasterisk.nvim`
- `kevinhwang91/nvim-bqf`
- `kevinhwang91/nvim-ufo`, `kevinhwang91/promise-async`
- `tris203/precognition.nvim`
- `gbprod/substitute.nvim`
- `tpope/vim-surround`
- `smjonas/inc-rename.nvim`
- `WilliamHsieh/overlook.nvim`
- `b0o/incline.nvim`
- `mvllow/modes.nvim`
- `TaDaa/vimade`
- `keaising/im-select.nvim`
- `mrjones2014/smart-splits.nvim`
- `andymass/vim-matchup`
- `nvim-treesitter/nvim-treesitter`
- `nvim-treesitter/nvim-treesitter-textobjects`
- `JoosepAlviste/nvim-ts-context-commentstring`
- `windwp/nvim-ts-autotag`
- `nvim-treesitter/nvim-treesitter-context`
- `folke/todo-comments.nvim`

**Disabled**

- `nvim-tree/nvim-tree.lua`
- `nvim-telescope/telescope.nvim`
