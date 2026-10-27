{lib, ...}: {
  flake-file.inputs = {
    browser-bookmarks = {
      url = "github:dhruvmanila/browser-bookmarks.nvim";
      flake = false;
    };
    github-coauthors = {
      url = "github:cwebster2/github-coauthors.nvim";
      flake = false;
    };
    tailiscope = {
      url = "github:danielvolchek/tailiscope.nvim";
      flake = false;
    };
    telescope-heading = {
      url = "github:crispgm/telescope-heading.nvim";
      flake = false;
    };
  };

  local.nvim.plugins =
    {
      telescope = {
        package = "telescope-nvim";
        lua =
          # lua
          ''
            {
              "telescope.nvim",
              cmd = "Telescope",
              on_require = "telescope",
              after = function()
                require("config.telescope").setup()
              end,
            }
          '';
      };

      browser-bookmarks = {
        input = "browser-bookmarks";
        dependencies = pkgs: [pkgs.vimPlugins.sqlite-lua];
        lua =
          # lua
          ''
            {
              "browser-bookmarks",
              dep_of = "telescope.nvim",
              main = "browser_bookmarks",
              opts = {
                selected_browser = "firefox",
                config_dir = vim.env.BROWSER_CONFIG_DIR,
              },
            }
          '';
      };

      git-worktree = {
        package = "git-worktree-nvim";
        lua =
          # lua
          ''{ "git-worktree.nvim", dep_of = "telescope.nvim" }'';
      };

      github-coauthors = {
        input = "github-coauthors";
        dependencies = pkgs: with pkgs.vimPlugins; [plenary-nvim telescope-nvim];
        lua =
          # lua
          ''{ "github-coauthors", dep_of = "telescope.nvim" }'';
      };

      tailiscope = {
        input = "tailiscope";
        dependencies = pkgs: with pkgs.vimPlugins; [plenary-nvim telescope-nvim];
        lua =
          # lua
          ''{ "tailiscope", dep_of = "telescope.nvim" }'';
      };

      telescope-heading = {
        input = "telescope-heading";
        dependencies = pkgs: with pkgs.vimPlugins; [plenary-nvim telescope-nvim];
        lua =
          # lua
          ''{ "telescope-heading", dep_of = "telescope.nvim" }'';
      };
    }
    // lib.genAttrs [
      "telescope-emoji"
      "telescope-fzf-native"
      "telescope-live-grep-args"
    ] (name: {
      package = "${name}-nvim";
      lua =
        # lua
        ''{ "${name}.nvim", dep_of = "telescope.nvim" }'';
    });
}
