---@type NvPluginSpec
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = function()
      -- Project-aware formatter selection.
      -- JS/TS: biome > eslint_d > prettier
      -- Other web files: dprint > prettier
      -- JSON: dprint > biome > prettier
      -- Prettierd runs only when a config is present; prettier is a final fallback.
      local util = require("conform.util")

      local eslint_files = {
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json",
      }
      local prettier_files = {
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        ".prettierrc",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.json",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        ".prettierrc.toml",
      }
      local oxlint_files = {
        "oxlint.config.js",
        "oxlint.config.mjs",
        "oxlint.config.cjs",
        ".oxlintrc",
        ".oxlintrc.json",
        ".oxlintrc.jsonc",
        ".oxlintrc.yaml",
        ".oxlintrc.yml",
        "oxlint.json",
        "oxlint.jsonc",
      }
      local oxfmt_files = {
        ".oxfmtrc.json",
        ".oxfmtrc.jsonc",
      }
      local black_files = { "pyproject.toml", "black.toml" }
      local isort_files = { ".isort.cfg", "pyproject.toml", "setup.cfg", "tox.ini" }
      local ruff_files = { "ruff.toml", ".ruff.toml", "pyproject.toml" }
      local eslint_root_files = vim.list_extend(vim.deepcopy(eslint_files), { "package.json" })
      local prettier_root_files = vim.list_extend(vim.deepcopy(prettier_files), { "package.json" })
      local oxlint_root_files = vim.list_extend(vim.deepcopy(oxlint_files), { "package.json" })
      local biome_files = { "biome.json", "biome.jsonc", "biome.toml" }
      local dprint_files = { "dprint.json", "dprint.jsonc" }

      local function has_file(ctx, files)
        return vim.fs.find(files, { path = ctx.dirname, upward = true })[1] ~= nil
      end

      local function read_file(path)
        local ok, content = pcall(vim.fn.readfile, path)
        if not ok or not content then
          return nil
        end
        return table.concat(content, "\n")
      end

      local function has_pyproject_section(ctx, section)
        local pyproject = vim.fs.find("pyproject.toml", { path = ctx.dirname, upward = true })[1]
        if not pyproject then
          return false
        end
        local content = read_file(pyproject)
        if not content then
          return false
        end
        return content:find("%[tool%." .. section) ~= nil
      end

      local function has_ini_section(ctx, filename, section)
        local ini = vim.fs.find(filename, { path = ctx.dirname, upward = true })[1]
        if not ini then
          return false
        end
        local content = read_file(ini)
        if not content then
          return false
        end
        return content:find("%[" .. section) ~= nil
      end

      local function has_package_json_key(ctx, key)
        local pkg = vim.fs.find("package.json", { path = ctx.dirname, upward = true })[1]
        if not pkg then
          return false
        end
        local ok, content = pcall(vim.fn.readfile, pkg)
        if not ok or not content then
          return false
        end
        local ok_decode, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
        if not ok_decode then
          return false
        end
        return type(decoded) == "table" and decoded[key] ~= nil
      end

      local function has_eslint(ctx)
        return has_file(ctx, eslint_files) or has_package_json_key(ctx, "eslintConfig")
      end

      local function has_prettier(ctx)
        return has_file(ctx, prettier_files) or has_package_json_key(ctx, "prettier")
      end

      local function has_biome(ctx)
        return has_file(ctx, biome_files)
      end

      local function has_dprint(ctx)
        return has_file(ctx, dprint_files)
      end

      local function has_oxlint(ctx)
        return has_file(ctx, oxlint_files) or has_package_json_key(ctx, "oxlint")
      end

      local function has_oxfmt(ctx)
        return has_file(ctx, oxfmt_files)
      end

      local function has_black(ctx)
        return has_file(ctx, { "black.toml" }) or has_pyproject_section(ctx, "black")
      end

      local function has_isort(ctx)
        return has_file(ctx, { ".isort.cfg" })
          or has_pyproject_section(ctx, "isort")
          or has_ini_section(ctx, "setup.cfg", "isort")
          or has_ini_section(ctx, "tox.ini", "isort")
      end

      local function has_ruff(ctx)
        return has_file(ctx, { "ruff.toml", ".ruff.toml" }) or has_pyproject_section(ctx, "ruff")
      end

      local js_formatters = {
        "biome",
        "oxfmt",
        "oxlint",
        "eslint_d",
        "prettierd",
        "prettier",
        stop_after_first = true,
      }
      local python_formatters = { "isort", "black", "ruff_format" }
      local json_formatters = { "dprint", "biome", "prettierd", "prettier", stop_after_first = true }
      local web_formatters = { "dprint", "prettierd", "prettier", stop_after_first = true }

      return {
        formatters_by_ft = {
          lua = { "stylua" },
          python = python_formatters,
          javascript = js_formatters,
          javascriptreact = js_formatters,
          typescript = js_formatters,
          typescriptreact = js_formatters,
          json = json_formatters,
          jsonc = json_formatters,
          html = web_formatters,
          css = web_formatters,
          scss = web_formatters,
          less = web_formatters,
          markdown = web_formatters,
          yaml = web_formatters,
          toml = web_formatters,
        },

        formatters = {
          biome = {
            condition = function(_, ctx)
              return has_biome(ctx)
            end,
            cwd = util.root_file(biome_files),
            require_cwd = true,
          },
          eslint_d = {
            condition = function(_, ctx)
              return has_eslint(ctx)
            end,
            cwd = util.root_file(eslint_root_files),
            require_cwd = true,
          },
          dprint = {
            condition = function(_, ctx)
              return has_dprint(ctx)
            end,
            cwd = util.root_file(dprint_files),
            require_cwd = true,
          },
          oxfmt = {
            condition = function(_, ctx)
              return has_oxfmt(ctx)
            end,
            cwd = util.root_file(oxfmt_files),
            require_cwd = true,
          },
          oxlint = {
            condition = function(_, ctx)
              return has_oxlint(ctx)
            end,
            cwd = util.root_file(oxlint_root_files),
            require_cwd = true,
          },
          isort = {
            condition = function(_, ctx)
              return has_isort(ctx)
            end,
            cwd = util.root_file(isort_files),
            require_cwd = true,
          },
          black = {
            condition = function(_, ctx)
              return has_black(ctx)
            end,
            cwd = util.root_file(black_files),
            require_cwd = true,
          },
          ruff_format = {
            condition = function(_, ctx)
              return has_ruff(ctx) and not has_black(ctx) and not has_isort(ctx)
            end,
            cwd = util.root_file(ruff_files),
            require_cwd = true,
          },
          prettierd = {
            condition = function(_, ctx)
              return has_prettier(ctx)
            end,
            cwd = util.root_file(prettier_root_files),
            require_cwd = true,
          },
          prettier = {
            cwd = util.root_file(prettier_root_files),
            require_cwd = false,
          },
        },

        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      }
    end,
  },
}
