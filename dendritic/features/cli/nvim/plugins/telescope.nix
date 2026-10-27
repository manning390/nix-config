# Fuzzy finding for files, buffers, text, bookmarks, and other project data.
# Load Telescope on command/API use and its extensions as dependencies.
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

      # Search browser bookmarks with <leader>pb. BROWSER_CONFIG_DIR selects the
      # Firefox directory; BROWSER_PROFILE optionally selects a profile by name.
      # The parser patch handles Windows line endings without changing Firefox
      # files. WSL opens URLs through wsl-open. Rebuild to apply plugin changes.
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

      # Create, switch, and delete Git worktrees through Telescope.
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
      # Select GitHub contributors to add Git co-author trailers.
      github-coauthors = ["plenary-nvim" "telescope-nvim"];
      # Search Tailwind CSS utility classes.
      tailiscope = ["plenary-nvim" "telescope-nvim"];
      # Navigate document headings through a Telescope picker.
      telescope-heading = ["plenary-nvim" "telescope-nvim"];
    }
    // lib.genAttrs [
      "telescope-emoji" # Search and insert emoji.
      "telescope-fzf-native" # Native fuzzy sorting for Telescope results.
      "telescope-live-grep-args" # Live grep with editable ripgrep arguments.
    ] (name: {
      package = "${name}-nvim";
      lua =
        # lua
        ''{ "${name}.nvim", dep_of = "telescope.nvim" }'';
    });
}
