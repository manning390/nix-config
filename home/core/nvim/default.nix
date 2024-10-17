{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-nightly;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-treesitter.withAllGrammars
    ];
  };

  home.packages = with pkgs; [
    devenv

    gcc
    gnumake
    nodejs_22

    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.neovim
    efm-langserver
    nixd
  ];

  programs.direnv.enable = true;

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
  xdg.configFile."nvim/after" = {
    recursive = true;
    source = ./after;
  };

  home.sessionVariables = {
    COLEMAK = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };
}
