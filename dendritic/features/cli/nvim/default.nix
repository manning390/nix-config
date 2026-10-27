{
  config,
  lib,
  ...
}: let
  plugins = config.local.nvim.plugins;
  nvim-options = (import ./options.nix).flake.modules.flake.nvim-options;
in {
  imports = [nvim-options];

  flake-file.inputs = {
    nvim-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nvim-nixpkgs";
      };
    };
  };

  # Expose metadata without evaluating host configurations or building packages.
  flake.nvim.updateInputs =
    ["nvim-nixpkgs" "neovim-nightly-overlay"]
    ++ (plugins
      |> builtins.attrValues
      |> builtins.filter (plugin: plugin.enable && plugin.input != null)
      |> map (plugin: plugin.input)
      |> lib.unique);

  flake.aspects.nvim = {
    description = "The goat editor";

    homeManager = {
      inputs,
      osConfig,
      pkgs,
      ...
    }: let
      neovim = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
      # Give editor plugins/tools their own update cadence. LuaRocks-backed
      # plugins must also use the nightly editor's LuaJIT package set.
      nvimPkgs = import inputs.nvim-nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        inherit (pkgs) config;
        overlays = [(_: _: {neovim-unwrapped = neovim;})];
      };
      bundle = import ./_bundle.nix {
        inherit lib inputs;
        plugins = lib.filterAttrs (_: plugin: plugin.enable && plugin.enableFor osConfig) plugins;
        pkgs = nvimPkgs;
      };
      runtimePathsLua =
        bundle.runtimePaths
        |> map toString
        |> lib.generators.toLua {};
    in {
      programs.neovim = {
        enable = true;
        package = neovim;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = false;

        plugins = bundle.packages;
        initLua =
          # lua
          ''
            for _, path in ipairs(${runtimePathsLua}) do
              vim.opt.runtimepath:prepend(path)
            end
            require("config")
          '';
      };

      home.packages =
        (with nvimPkgs; [
          devenv
          ripgrep
          nodejs

          # LSP
          tree-sitter
          lua-language-server
          svelte-language-server
          neovim-node-client
          typescript
          typescript-language-server
          eslint
          eslint_d
          emmet-language-server
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
          (with dotnetCorePackages;
            combinePackages [
              sdk_8_0
              sdk_10_0
            ])
          dotnet-ef
          csharpier
        ])
        ++ bundle.extraPackages;

      xdg.configFile = {
        "nvim/lua" = {
          recursive = true;
          source = ./lua;
        };
        "nvim/lua/config/plugin-specs.lua".text = bundle.lua;
        "nvim/snippets" = {
          recursive = true;
          source = ./snippets;
        };
      };

      programs.direnv.enable = true;

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
        DIRENV_LOG_FORMAT = "";
      };
    };
  };
}
