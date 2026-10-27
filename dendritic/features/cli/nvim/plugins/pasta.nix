{
  local.nvim.plugins.pasta = {
    package = "vim-pasta";
    lua =
      # lua
      ''
        {
          "vim-pasta",
          beforeAll = function()
            vim.g.pasta_disabled_filetypes = { "fugitive" }
          end,
        }
      '';
  };
}
