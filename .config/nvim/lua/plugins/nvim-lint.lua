---@type NvPluginSpec
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require "lint"

      local function read_file(pathname)
        local ok, content = pcall(vim.fn.readfile, pathname)
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

      local function has_package_json_key(ctx, key)
        local pkg = vim.fs.find("package.json", { path = ctx.dirname, upward = true })[1]
        if not pkg then
          return false
        end
        local content = read_file(pkg)
        if not content then
          return false
        end
        local ok, decoded = pcall(vim.json.decode, content)
        if not ok then
          return false
        end
        return type(decoded) == "table" and decoded[key] ~= nil
      end

      local function has_eslint(ctx)
        return vim.fs.find(eslint_files, { path = ctx.dirname, upward = true })[1] ~= nil
          or has_package_json_key(ctx, "eslintConfig")
      end

      local function has_ruff(ctx)
        return vim.fs.find({ "ruff.toml", ".ruff.toml" }, { path = ctx.dirname, upward = true })[1] ~= nil
          or has_pyproject_section(ctx, "ruff")
      end

      local function has_flake8(ctx)
        return vim.fs.find(".flake8", { path = ctx.dirname, upward = true })[1] ~= nil
          or has_ini_section(ctx, "setup.cfg", "flake8")
          or has_ini_section(ctx, "tox.ini", "flake8")
          or has_pyproject_section(ctx, "flake8")
      end

      local function python_linters(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return {}
        end
        local ctx = { dirname = vim.fs.dirname(name) }
        if has_ruff(ctx) then
          return { "ruff" }
        end
        if has_flake8(ctx) then
          return { "flake8" }
        end
        return {}
      end

      local js_filetypes = {
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
      }

      local function js_linters(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return {}
        end
        local ctx = { dirname = vim.fs.dirname(name) }
        if has_eslint(ctx) then
          return { "eslint_d" }
        end
        return {}
      end

      lint.linters_by_ft = {}

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.bo[bufnr].filetype
          if filetype == "python" then
            local linters = python_linters(bufnr)
            if #linters > 0 then
              lint.try_lint(linters)
            end
            return
          end
          if js_filetypes[filetype] then
            local linters = js_linters(bufnr)
            if #linters > 0 then
              lint.try_lint(linters)
            end
            return
          end
          lint.try_lint()
        end,
      })
    end,
  },
}
