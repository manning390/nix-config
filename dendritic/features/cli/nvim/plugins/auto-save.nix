{
  local.nvim.plugins.auto-save = {
    package = "auto-save-nvim";
    lua =
      # lua
      ''
        { "auto-save.nvim", cmd = "ASToggle", main = "auto-save", opts = {} }
      '';
  };
}
