# Writing tools from the custom wrd.nvim plugin.
# Load through :Wrd or its Lua API.
{
  flake-file.inputs.wrd-nvim = {
    url = "github:manning390/wrd.nvim/dev";
    flake = false;
  };

  local.nvim.plugins.wrd = {
    input = "wrd-nvim";
    dependencies = pkgs: with pkgs.vimPlugins; [plenary-nvim telescope-nvim];
    lua =
      # lua
      ''
        {
          "wrd-nvim",
          cmd = "Wrd",
          on_require = "wrd",
          main = "wrd",
          opts = {},
        }
      '';
  };
}
