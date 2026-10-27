{
  local.nvim.plugins.lspkind = {
    package = "lspkind-nvim";
    lua =
      # lua
      ''{ "lspkind.nvim", on_require = "lspkind" }'';
  };
}
