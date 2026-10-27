# Align selected text into columns; loaded when an alignment mapping requires it.
{
  local.nvim.plugins.align = {
    package = "align-nvim";
    lua =
      # lua
      ''{ "align.nvim", on_require = "align" }'';
  };
}
