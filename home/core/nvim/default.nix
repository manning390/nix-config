{
  config,
  pkgs,
  lib,
  ...
}: let
  tailiscope-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "tailiscope-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "danielvolchek";
      repo = "tailiscope.nvim";
      rev = "d756e166cc1fec4eb06549b218b275c21d652e1e";
      hash = "sha256-rIRjxXhcXSM0opKWtNLp4fwOh2mZLD1TiYkHMk3aiXk=";
    };
  };
  telescope-heading-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "telescope-heading-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "crispgm";
      repo = "telescope-heading.nvim";
      rev = "v0.7.0";
      hash = "sha256-1dSGm+FQ/xb4CRPzI4Fc/bq1XyW54MOWCEddBnSsYCU=";
    };
  };
  browser-bookmarks-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "browser-bookmarks-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "dhruvmanila";
      repo = "browser-bookmarks.nvim";
      rev = "v4.0.0";
      hash = "sha256-eoNC0JgaqFh1zb/Sf13i90rKepz9mz6achOYjROU8Es=";
    };
  };
  github-coauthors-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "github-coauthors-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "cwebster2";
      repo = "github-coauthors.nvim";
      rev = "3cf0bf406fcbb9b442589c05b306bfe11e1d27b0";
      hash = "sha256-eoNC0JgaqFh1zb/Sf13i90rKepz9mz6achOYjROU8Es=";
    };
  };
in {
  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-nightly;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-lspconfig
      nvim-notify

      nvim-treesitter.withAllGrammars

      telescope-nvim
      telescope-live-grep-args-nvim
      telescope-fzf-native-nvim
      tailiscope-nvim
      telescope-heading-nvim
      browser-bookmarks-nvim
      github-coauthors-nvim

      vim-fugitive
      vim-rhubarb

      comment-nvim
    ];

    extraLuaConfig = ''
      vim.g.mapleader = "'";
      vim.g.maplocalleader = "'";
      require("lazy").setup({
       performance = {
                reset_packpath = false,
                rtp = {
                  reset = false,
                },
                dev = {
                  path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackage/start",
                  patterns = {""},
                },
                install = {
                  missing = false,
                },
         },
                spec = {
                  { import = "plugins" },
                },
              })
       require'config'
    '';
  };

  home.file."${config.xdg.configHome}/nvim/lua" = {
    recursive = true;
    source = ./lua;
  };

  home.sessionVariables = {
    COLEMAK = "1";
    EDITOR = "nvim";
  };
}
