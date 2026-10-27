{
  local.nvim.plugins.surround = {
    package = "nvim-surround";
    lua =
      # lua
      ''
        {
          "nvim-surround",
          event = "DeferredUIEnter",
          main = "nvim-surround",
          opts = {},
        }
      '';
  };
}
