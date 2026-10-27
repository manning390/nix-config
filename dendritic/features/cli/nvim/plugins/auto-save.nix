# Automatically save changed buffers once enabled through :ASToggle.
# Command loading intentionally leaves automatic saving inactive at startup.
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
