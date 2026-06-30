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
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-treesitter.withAllGrammars
    ];
  };

  home.packages = with pkgs; [
    devenv
    ripgrep
    nodejs

    # LSP
    tree-sitter
    cmake-language-server
    lua-language-server
    svelte-language-server
    neovim-node-client
    typescript
    typescript-language-server
    eslint
    eslint_d
    emmet-language-server
    efm-langserver
    nixd
    vale-ls
    vscode-langservers-extracted
    tailwindcss-language-server

    # Formatter
    stylua
    codespell
    prettierd
    fixjson

    # dotnet
    (with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_10_0
      ])
    dotnet-ef
    csharpier
  ];

  programs.direnv.enable = true;

  xdg.configFile."nvim/init.lua".source = let
    grammarsPath = toString (pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    });
  in
    pkgs.writeText "init.lua" ''
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
