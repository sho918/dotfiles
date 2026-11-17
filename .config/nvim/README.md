# Neovim Config

## Overview

- Leader: `<Space>`
- Plugin manager: `lazy.nvim`
- Lazy.nvim rocks support is enabled for Neorg dependencies.
- Tree-sitter: `nvim-treesitter` main branch for Neovim 0.12+, with the `tree-sitter` CLI managed by `Brewfile`.
- `:TSInstallAll` installs every parser listed in `lua/plugins/nvim-treesitter.lua`.
- Tabline: theme toggle button is disabled
- Bare `nvim` and `nvim .` start with `snacks.dashboard` instead of NvChad `nvdash`
- `cd ~/neorg && nvim` and `nvim ~/neorg` open `~/neorg/index.norg`
- Oil shows dotfiles by default; use `g.` inside Oil to toggle hidden entries

## Startup Dashboard

- The startup screen is powered by `snacks.dashboard`.
- Starting with a single directory argument keeps that directory as `cwd` and still opens the dashboard.
- Starting with the exact `~/neorg` directory opens `~/neorg/index.norg` instead of the dashboard.
- `Recent Projects` is inferred from the project roots of recently opened files.
- Selecting a project switches to that directory and immediately opens the file picker there.
- The startup shortcuts are intentionally minimal: find files, grep, recent files, config, and quit.
- Dashboard shortcuts are displayed on consecutive lines without blank rows between items.

## Neorg

- Neorg is installed via `nvim-neorg/neorg` and requires `luarocks`.
- The default Neorg workspace is `notes = ~/neorg`.
- The workspace index file is `~/neorg/index.norg`.
- Journal entries are stored under `~/neorg/journal` with the nested date strategy.
- Useful commands:
  - `:Neorg workspace` shows the current workspace.
  - `:Neorg workspace notes` switches to the notes workspace.
  - `:Neorg journal today` opens today's journal entry.
  - `:Neorg journal custom YYYY-mm-dd` opens a journal entry for a specific date.
  - `:Neorg journal toc open` opens the journal table of contents.
  - `:Neorg journal toc update` updates the journal table of contents.
- In `.norg` files, `<C-Space>` cycles TODO states.

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

### Custom overrides and plugin-generated maps

| Category     | Keys                | Description                                           |
| ------------ | ------------------- | ----------------------------------------------------- |
| Basic        | `;`                 | Command line                                          |
| Basic        | `<Esc>`             | Clear multicursor/search highlight                    |
| Completion   | Insert `<Tab>`      | Confirm selected completion                           |
| Movement     | Insert `<C-p>`      | Move up                                               |
| Movement     | Insert `<C-n>`      | Move down                                             |
| Movement     | Insert `<C-b>`      | Move left                                             |
| Movement     | Insert `<C-f>`      | Move right                                            |
| Oil          | Normal `<C-n>`      | Oil: Move down                                        |
| Oil          | Normal `<C-p>`      | Oil: Move up                                          |
| Oil          | Normal `g.`         | Oil: Toggle hidden files                              |
| Save/Quit    | `<leader>ww`        | Save                                                  |
| Save/Quit    | `<leader>q`         | Close buffer                                          |
| Buffer       | `<leader>bb`        | New buffer                                            |
| Buffer       | `<leader>bn`        | Next buffer                                           |
| Buffer       | `<leader>bp`        | Previous buffer                                       |
| Buffer       | `<leader>bd`        | Delete buffer                                         |
| Buffer       | `<leader>bD`        | Force delete buffer                                   |
| Buffer       | `<leader>bl`        | Last buffer                                           |
| Buffer       | `<leader>br`        | Reload current buffer                                 |
| Buffer       | `<leader>bo`        | Delete other buffers                                  |
| Split        | `<leader>-`         | Horizontal split                                      |
| Split        | `<leader>\`         | Vertical split                                        |
| Editing      | `J`                 | Join arguments in brackets, otherwise native line join |
| Editing      | `gS`                | Toggle split/join arguments (`mini.splitjoin`)        |
| Editing      | `ga`                | Align without preview (`mini.align`)                  |
| Editing      | `gA`                | Align with preview (`mini.align`)                     |
| Window       | `<C-h>`             | Move left window (smart-splits)                       |
| Window       | `<C-j>`             | Move down window (smart-splits)                       |
| Window       | `<C-k>`             | Move up window (smart-splits)                         |
| Window       | `<C-l>`             | Move right window (smart-splits)                      |
| Line Move    | Visual `<C-j>`      | Move selection down                                   |
| Line Move    | Visual `<C-k>`      | Move selection up                                     |
| Line Move    | Normal `<M-l>`      | Move current line right (`mini.move`)                 |
| Line Move    | Normal `<M-j>`      | Move current line down (`mini.move`)                  |
| Line Move    | Normal `<M-k>`      | Move current line up (`mini.move`)                    |
| Line Move    | Visual `<M-h>`      | Move selection left (`mini.move`)                     |
| Line Move    | Visual `<M-l>`      | Move selection right (`mini.move`)                    |
| Line Move    | Visual `<M-j>`      | Move selection down (`mini.move`)                     |
| Line Move    | Visual `<M-k>`      | Move selection up (`mini.move`)                       |
| Git          | `<leader>gg`        | LazyGit                                |
| Git          | `<leader>gl`        | LazyGit log                            |
| Git          | `<leader>gf`        | LazyGit current file history            |
| Git          | `<leader>gd`        | CodeDiff worktree                      |
| Git          | `<leader>gD`        | CodeDiff previous commit               |
| Git          | `<leader>gs`        | CodeDiff staged                        |
| Git          | `<leader>gh`        | File history                           |
| Git          | `<leader>gH`        | Branch history                         |
| Git          | `<leader>gm`        | CodeDiff main                          |
| Git          | `<leader>gM`        | CodeDiff master                        |
| Git          | `<leader>gr`        | PR review menu                         |
| Git          | Visual `<leader>gr` | PR suggest change                      |
| Git          | `<leader>gq`        | CodeDiff close (diff view only)         |
| Git          | `<leader>gt`        | CodeDiff file panel (explorer only)     |
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
| Oil          | `<leader>e`         | Oil float toggle (hidden shown by default) |
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
| MultiCursor  | `<C-g>`             | Add next match (multicursor.nvim)      |
| Substitute   | `gr`                | Replace operator                       |
| Substitute   | `grr`               | Replace line                           |
| Substitute   | Visual `gr`         | Replace selection                      |

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
| Tabufline | `<leader>b`  | Disabled (used as buffer prefix) |
| Tabufline | `<tab>`      | Next buffer                  |
| Tabufline | `<S-tab>`    | Previous buffer              |
| Tabufline | `<leader>x`  | Close buffer                 |

## Plugins

**Base**

- `NvChad/NvChad`
- `folke/lazy.nvim`

**Completion/AI**

- `saghen/blink.cmp`, `fang2hou/blink-copilot`
- `zbirenbaum/copilot.lua`

**LSP/Format/Lint**

- `neovim/nvim-lspconfig`
- `ray-x/lsp_signature.nvim`
- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`

**Python/Venv**

- `linux-cultist/venv-selector.nvim`
- `venv-selector.nvim` keeps `vim.notify` owned by `noice.nvim` (`override_notify = false`) to avoid notification handler conflicts

**Search/File**

- `folke/snacks.nvim`
- `stevearc/oil.nvim`

**Git**

- `lewis6991/gitsigns.nvim`
- `esmuellert/codediff.nvim`
- `Yu-Leo/blame-column.nvim`
- `otavioschwanck/github-pr-reviewer.nvim`

**UI/Editing**

- `nvim-neorg/neorg`
- `folke/noice.nvim`, `MunifTanjim/nui.nvim`
- `folke/trouble.nvim`
- `folke/flash.nvim`
- `jake-stewart/multicursor.nvim`
- `rapan931/lasterisk.nvim`
- `nvim-mini/mini.nvim` (`mini.align`, `mini.cursorword`, `mini.extra`, `mini.move`, `mini.splitjoin`, `mini.trailspace`)
- `kevinhwang91/nvim-bqf`
- `kevinhwang91/nvim-ufo`, `kevinhwang91/promise-async`
- `tris203/precognition.nvim`
- `gbprod/substitute.nvim`
- `kylechui/nvim-surround`
- `smjonas/inc-rename.nvim`
- `WilliamHsieh/overlook.nvim`
- `b0o/incline.nvim`
- [`modes.nvim`](https://git.sr.ht/~mellow/modes.nvim) (SourceHut)
- `TaDaa/vimade`
- `keaising/im-select.nvim`
- `smart-splits-nvim/smart-splits.nvim`, `smart-splits-nvim/backend-wezterm`
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

## Mini Module Scope

- Enabled: `mini.align`, `mini.cursorword`, `mini.extra`, `mini.move`, `mini.splitjoin`, `mini.trailspace`
- `mini.move` keeps default mappings except Normal `<M-h>`, which stays bound to NvChad's horizontal terminal toggle.
- Trailing full-width spaces (`U+3000`) are also highlighted.

## Plugin integrations

- Snacks provides notifications and lazygit integration; Noice keeps message routing and command-line UI.
- CodeDiff v4 replaces Diffview. Existing Git prefixes stay the same; `<leader>gq` closes a CodeDiff view and `<leader>gt` toggles the file panel in its explorer view.
- CodeDiff downloads its native diff library on first use.
- `nvim-surround` v4 keeps the core `ys`, `ds`, and `cs` operations.
- `modes.nvim` loads automatically from SourceHut and derives mode colors from the active theme; the previous `setup()` options are no longer used.
- Smart-splits v3 enables its WezTerm backend only when both `WEZTERM_PANE` and `SMART_SPLITS_WEZTERM` are available. Existing panes without the handshake and other terminals use Neovim-only window movement without a backend warning. `.config/wezterm/wezterm.lua` loads the matching GUI plugin and blocks pane navigation while zoomed. Start a new WezTerm window after reloading its config to enable cross-pane navigation.
- Blink stays on the NvChad-provided `1.*` version constraint; Copilot completion remains enabled.
