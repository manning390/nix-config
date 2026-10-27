# Statusline with Git branch, file, Harpoon, word-count, and cursor information.
# Initialize after the UI starts, with Harpoon loaded first.
{
  local.nvim.plugins.lualine = {
    package = "lualine-nvim";
    lua =
      # lua
      ''
        {
          "lualine.nvim",
          event = "DeferredUIEnter",
          on_require = "lualine",
          after = function()
            require("config.lualine")
          end,
        }
      '';
  };
}
