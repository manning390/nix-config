let
  # Locked source inputs for external plugins and existing optional experiments.
  # Prefer pkgs.vimPlugins when a package is available.
  externalPlugins = {
    cmp-async-path = "git+https://codeberg.org/FelipeLema/cmp-async-path";
    telescope-emoji = "github:xiyaowong/telescope-emoji.nvim";
    telescope-heading = "github:crispgm/telescope-heading.nvim";
    tailiscope = "github:danielvolchek/tailiscope.nvim";
    browser-bookmarks = "github:dhruvmanila/browser-bookmarks.nvim";
    github-coauthors = "github:cwebster2/github-coauthors.nvim";
    phpactor-nvim = "github:gbprod/phpactor.nvim/v1.0.1";
    wrd-nvim = "github:manning390/wrd.nvim/dev";
  };
in {
  flake-file.inputs =
    {
      neovim-nightly-overlay = {
        url = "github:nix-community/neovim-nightly-overlay";
        inputs = {
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs-unstable";
        };
      };
    }
    // (builtins.mapAttrs (_: url: {
        inherit url;
        flake = false;
      })
      externalPlugins);

  flake.aspects.nvim = {
    description = "The goat editor";

    homeManager = {
      inputs,
      pkgs,
      ...
    }: let
      neovim = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
      # LuaRocks-backed vimPlugins must use the same LuaJIT as the nightly editor.
      # Keep nixpkgs' plugin recipes, but build their Lua dependencies for Neovim.
      pluginPkgs = pkgs.extend (_: _: {neovim-unwrapped = neovim;});
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

        plugins = import ./_plugins.nix {
          inherit inputs externalPlugins;
          pkgs = pluginPkgs;
        };

        initLua = let
          grammarsPath = toString (pkgs.symlinkJoin {
            name = "nvim-treesitter-grammars";
            paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
          });
          svelteGrammarWithAttach = pkgs.neovimUtils.grammarToPlugin (pkgs.vimPlugins.nvim-treesitter.grammarPlugins.svelte.origGrammar.overrideAttrs (old: {
            patches = (old.patches or []) ++ [./tree-sitter-svelte-pr-20.patch];
          }));
        in
          #lua
          ''
            vim.opt.runtimepath:prepend("${grammarsPath}")
            vim.opt.runtimepath:prepend("${svelteGrammarWithAttach}")
            require'config'
          '';
      };

      home.packages = import ./_packages.nix {inherit pkgs;};

      programs.direnv.enable = true;

      xdg.configFile = {
        "nvim/lua" = {
          recursive = true;
          source = ./lua;
        };
        "nvim/snippets" = {
          recursive = true;
          source = ./snippets;
        };
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
        DIRENV_LOG_FORMAT = "";
      };
    };
  };
}
