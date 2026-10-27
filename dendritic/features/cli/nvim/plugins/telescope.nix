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
        overrideAttrs = old: {
          patches = (old.patches or []) ++ [../browser-bookmarks-crlf.patch];
        };
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
                profile_name = vim.env.BROWSER_PROFILE,
                url_open_command = vim.fn.has("wsl") == 1 and "wsl-open" or nil,
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
    }
    // lib.mapAttrs (name: deps: {
      input = name;
      dependencies = pkgs: map (dep: pkgs.vimPlugins.${dep}) deps;
      lua =
        # lua
        ''{ "${name}", dep_of = "telescope.nvim" }'';
    }) {
      github-coauthors = ["plenary-nvim" "telescope-nvim"];
      tailiscope = ["plenary-nvim" "telescope-nvim"];
      telescope-heading = ["plenary-nvim" "telescope-nvim"];
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
