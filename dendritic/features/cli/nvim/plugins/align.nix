{
  local.nvim.plugins.align = {
    package = "align-nvim";
    lua =
      # lua
      ''{ "align.nvim", on_require = "align" }'';
  };
}
