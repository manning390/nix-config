# Expand snippets and navigate placeholders; load with completion or snippet mappings.
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
