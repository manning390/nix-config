{
  local.nvim.plugins = {
    treesitter = {
      package = pkgs: pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      optional = false;
      runtimePaths = pkgs: [
        (pkgs.symlinkJoin {
          name = "nvim-treesitter-grammars";
          paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
        })
        # @attach support: upstream PR #20 waiting for merge.
        # https://github.com/tree-sitter-grammars/tree-sitter-svelte/pull/20
        (pkgs.neovimUtils.grammarToPlugin (pkgs.vimPlugins.nvim-treesitter.grammarPlugins.svelte.origGrammar.overrideAttrs (old: {
          patches = (old.patches or []) ++ [../tree-sitter-svelte-pr-20.patch];
        })))
      ];
    };

    context-commentstring = {
      package = "nvim-ts-context-commentstring";
      lua =
        # lua
        ''
          { "nvim-ts-context-commentstring", dep_of = { "comment.nvim", "nvim-treesitter-textobjects" } }
        '';
    };

    treesitter-textobjects = {
      package = "nvim-treesitter-textobjects";
      lua =
        # lua
        ''
          {
            "nvim-treesitter-textobjects",
            after = function()
              require("config.treesitter")
            end,
          }
        '';
    };

    treesj = {
      package = "treesj";
      lua =
        # lua
        ''
          {
            "treesj",
            on_require = "treesj",
            cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
            after = function()
              require("config.treesj")
            end,
          }
        '';
    };
  };
}
