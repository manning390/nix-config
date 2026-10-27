{
  local.nvim.plugins.neoscroll = {
    package = "neoscroll-nvim";
    lua =
      # lua
      ''
        {
          "neoscroll.nvim",
          event = "DeferredUIEnter",
          main = "neoscroll",
          opts = {},
        }
      '';
  };
}
