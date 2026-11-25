# Format buffers with external formatters and optional LSP fallback.
# Load when formatting commands or formatexpr require it.
{
  local.nvim.plugins.conform = {
    package = "conform-nvim";
    lua =
      # lua
      ''
        {
          "conform.nvim",
          on_require = "conform", -- Also covers formatexpr and :Format.
          main = "conform",
          opts = {
            formatters_by_ft = {
              lua = { "stylua" },
              typescript = { "prettierd", "prettier", stop_after_first = true },
              typescriptreact = { "prettierd", "prettier", stop_after_first = true },
              javascript = { "prettierd", "prettier", stop_after_first = true },
              javascriptreact = { "prettierd", "prettier", stop_after_first = true },
              html = { "prettierd", "prettier", stop_after_first = true },
              svelte = { "prettierd", "prettier", stop_after_first = true },
              php = { "pint" },
              nix = { "alejandra" },
              json = { "fixjson", "jq" },
              json5 = { "fixjson" },
              cs = { "csharpier" },
              ["_"] = function(bufnr)
                return vim.b[bufnr].writing_mode and {} or { "codespell" }
              end,
              ["*"] = function(bufnr)
                return vim.b[bufnr].writing_mode and {} or { "trim_whitespace" }
              end,
            },
            default_format_opts = { lsp_format = "fallback" },
          },
        }
      '';
  };
}
