{
  local.nvim.plugins.smear-cursor = {
    enableFor = config: config.wsl.enable or false;
    package = "smear-cursor-nvim";
    lua =
      # lua
      ''
        {
          "smear-cursor.nvim",
          event = "DeferredUIEnter",
          main = "smear_cursor",
          opts = { }
        }
      '';
  };
}
