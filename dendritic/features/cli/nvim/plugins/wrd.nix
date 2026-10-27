{
  flake-file.inputs.wrd-nvim = {
    url = "github:manning390/wrd.nvim/dev";
    flake = false;
  };

  local.nvim.plugins.wrd = {
    enable = false;
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
