# Bookmark project files for quick navigation and statusline indicators.
# Load before the statusline or when a navigation mapping requires it.
{
  local.nvim.plugins.harpoon = {
    package = "harpoon2";
    lua =
      # lua
      ''
        {
          "harpoon2",
          on_require = "harpoon",
          dep_of = "lualine.nvim", -- The statusline reads Harpoon's list.
          after = function()
            -- Harpoon uses a method, not a plain setup(opts) function.
            require("harpoon"):setup({
              settings = { save_on_toggle = true, sync_on_ui_close = true },
            })
          end,
        }
      '';
  };
}
