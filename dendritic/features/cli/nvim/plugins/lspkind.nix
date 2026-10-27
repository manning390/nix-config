# Symbol-kind icons for completion entries; load when completion formatting requires it.
{
  local.nvim.plugins.lspkind = {
    package = "lspkind-nvim";
    lua =
      # lua
      ''{ "lspkind.nvim", on_require = "lspkind" }'';
  };
}
