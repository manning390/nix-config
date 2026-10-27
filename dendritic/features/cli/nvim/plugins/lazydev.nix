{
  local.nvim.plugins.lazydev = {
    package = "lazydev-nvim";
    lua =
      # lua
      ''
        { "lazydev.nvim", ft = "lua", main = "lazydev", opts = {} }
      '';
  };
}
