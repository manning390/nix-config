let
  # These are neovim plugins not in the nix store
  externalPlugins = {
    cmp-async-path = "git+https://codeberg.org/FelipeLema/cmp-async-path";
    telescope-emoji = "github:xiyaowong/telescope-emoji.nvim";
    telescope-heading = "github:crispgm/telescope-heading.nvim";
    tailiscope = "github:danielvolchek/tailiscope.nvim";
    tailwind-fold = "github:razak17/tailwind-fold.nvim";
    browser-bookmarks = "github:dhruvmanila/browser-bookmarks.nvim";
    github-coauthors = "github:cwebster2/github-coauthors.nvim";
    none-ls-extras = "github:nvimtools/none-ls-extras.nvim";
    none-ls-php = "github:gbprod/none-ls-php.nvim";
    wrd-nvim = "github:manning390/wrd.nvim/dev";
  };
in {
  flake-file.inputs =
    {
      neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
        
	plugins = [
	    pkgs.vimPlugins.lazy-nvim
	    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
	];
        # plugins = import ./_plugins.nix {inherit inputs pkgs externalPlugins;};

        initLua = let
          grammarsPath = toString (pkgs.symlinkJoin {
            name = "nvim-treesitter-grammars";
            paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
          });
        in
          #lua
          ''
            vim.opt.runtimepath:prepend("${grammarsPath}")
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
        "nvim/after" = {
          recursive = true;
          source = ./after;
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
