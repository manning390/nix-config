{
  local.nvim.plugins.cmp = {
    package = "nvim-cmp";
    lua =
      # lua
      ''
        {
          "nvim-cmp",
          event = "InsertEnter",
          on_require = "cmp",
          before = function()
            require("lze").trigger_load("nvim-autopairs")
          end,
          after = function()
            require("config.cmp")
          end,
        }
      '';
  };
}
