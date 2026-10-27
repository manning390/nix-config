{
  local.nvim.plugins.markdown-preview = {
    package = "markdown-preview-nvim";
    lua =
      # lua
      ''
        {
          "markdown-preview.nvim",
          cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
          ft = "markdown",
          beforeAll = function()
            vim.g.mkdp_theme = "dark"
            vim.g.mkdp_markdown_css = ""
          end,
        }
      '';
  };
}
