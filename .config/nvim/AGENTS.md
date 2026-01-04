# Guidelines

## プロジェクト構成

- `init.lua` で Lazy.nvim を起動し、NvChad とローカル設定を読み込みます。
- `lua/` 配下に設定を集約します。
  - `lua/plugins/`：プラグイン定義・設定
  - `lua/configs/`：共通設定のみ（例: `lazy.lua`）
  - 基本設定は `lua/options.lua`, `lua/mappings.lua`, `lua/autocmds.lua`, `lua/chadrc.lua`
- `lazy-lock.json` は Lazy.nvim が生成するロックファイルです。
- `.stylua.toml` は Lua フォーマット設定です。

## 変更方針

- 追加設定は `init.lua` ではなく該当モジュールに整理します。
- 設定変更を行った場合は、必ず `README.md` も更新して内容を反映してください。

## 開発コマンド

- `nvim` — この設定で Neovim を起動します。
- `nvim --headless "+Lazy sync" +qa` — CLI でプラグインを同期します。
- `stylua .` — Lua の整形を実行します。

## コーディングスタイル

- Stylua 準拠（2 スペース、120 カラム、ダブルクォート優先）。
- モジュール名はパスと一致させます（例: `lua/plugins/flash.lua`）。
