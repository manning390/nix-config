# Nord color scheme; apply early to avoid flashing an unstyled UI.
{
  local.nvim.plugins.nord = {
    package = "nord-nvim";
    lua =
      # lua
      ''
        {
          "nord.nvim",
          priority = 1000,
          after = function()
            vim.o.background = "dark"
            vim.cmd.colorscheme("nord")
          end,
        }
      '';
  };
}
