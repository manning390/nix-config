{
  local.nvim.plugins.luasnip = {
    package = "luasnip";
    lua =
      # lua
      ''
        {
          "luasnip",
          on_require = "luasnip",
          dep_of = "nvim-cmp",
          after = function()
            require("config.snippets")
          end,
        }
      '';
  };
}
