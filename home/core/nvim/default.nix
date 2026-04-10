{
  inputs,
  pkgs,
  ...
}: {
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
    ripgrep

    # LSP
    tree-sitter
    cmake-language-server
    lua-language-server
    neovim-node-client
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    eslint_d
    efm-langserver
    nixd
    vale-ls

    # Formatter
    stylua
    codespell

    # dotnet
    (with pkgs.dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_10_0
    ])
    dotnet-ef
    csharpier
  ];

  programs.direnv.enable = true;

  xdg.configFile."nvim/init.lua".source = let
    grammarsPath = builtins.toString (pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    });
  in pkgs.writeText "init.lua" ''
    vim.opt.runtimepath:prepend("${grammarsPath}")

    require'config'
  '';
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
