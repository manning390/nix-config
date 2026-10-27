{
  local.nvim.plugins.notifier = {
    package = "notifier-nvim";
    lua =
      # lua
      ''
        {
          "notifier.nvim",
          priority = 70,
          beforeAll = function()
            -- Compatibility with recent Neovim nightlies.
            vim.tbl_islist = vim.tbl_islist or vim.islist
          end,
          main = "notifier",
          opts = {},
        }
      '';
  };
}
