{
  inputs,
  pkgs,
  ...
}: let
in {
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
    nodejs
    pnpm
    # intelephense
    python3

    # LSP
    lua-language-server
    neovim-node-client
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    eslint_d
    efm-langserver
    nixd
    vale-ls
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
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };
}
