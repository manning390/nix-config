{
  local.nvim.plugins.dressing = {
    package = "dressing-nvim";
    lua =
      # lua
      ''
        {
          "dressing.nvim",
          on_require = "dressing",
          event = "DeferredUIEnter",
          main = "dressing",
          opts = {},
        }
      '';
  };
}
