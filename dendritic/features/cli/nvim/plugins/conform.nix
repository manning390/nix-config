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
              ["_"] = { "codespell" },
              ["*"] = { "trim_whitespace" },
            },
            default_format_opts = { lsp_format = "fallback" },
          },
        }
      '';
  };
}
