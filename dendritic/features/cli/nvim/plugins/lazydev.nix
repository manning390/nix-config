# Neovim-aware Lua language-server types and completion; load only for Lua buffers.
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
