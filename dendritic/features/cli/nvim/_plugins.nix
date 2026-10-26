{
  inputs,
  pkgs,
  externalPlugins,
}: let
  # Nix owns sources, versions, native builds, and dependencies. Lua owns setup.
  externalDependencies = with pkgs.vimPlugins; {
    browser-bookmarks = [sqlite-lua];
    github-coauthors = [plenary-nvim telescope-nvim];
    phpactor-nvim = [plenary-nvim nvim-lspconfig];
    telescope-heading = [plenary-nvim telescope-nvim];
    tailiscope = [plenary-nvim telescope-nvim];
  };
  external = builtins.mapAttrs (name: _:
    pkgs.vimUtils.buildVimPlugin {
      pname = name;
      version = inputs.${name}.shortRev or "locked";
      src = inputs.${name};
      dependencies = externalDependencies.${name} or [];
    })
  externalPlugins;
  optional = plugin: {
    inherit plugin;
    optional = true;
  };
in
  with pkgs.vimPlugins;
    [
      lze

      # Shared Lua libraries and completion capabilities are available at startup.
      plenary-nvim
      nui-nvim
      sqlite-lua
      cmp-nvim-lsp

      # Parser installation is exclusively managed by Nix.
      nvim-treesitter.withAllGrammars
    ]
    ++ map optional [
      nvim-lspconfig
      lazydev-nvim
      typescript-tools-nvim
      external.phpactor-nvim
      conform-nvim
      notifier-nvim

      luasnip
      nvim-cmp
      cmp-buffer
      cmp-calc
      cmp-spell
      cmp-nvim-lua
      cmp-path
      cmp-async-path
      cmp_luasnip
      cmp-nvim-lsp-signature-help
      lspkind-nvim

      nvim-ts-context-commentstring
      nvim-treesitter-textobjects
      vim-tmux-navigator
      vim-speeddating
      vim-fugitive
      vim-rhubarb
      gitsigns-nvim
      git-worktree-nvim
      refactoring-nvim

      nord-nvim
      lualine-nvim
      nvim-web-devicons
      indent-blankline-nvim
      comment-nvim
      treesj
      vim-abolish
      vim-eunuch
      vim-repeat
      vim-sleuth
      vim-unimpaired
      nvim-surround
      align-nvim
      todo-comments-nvim
      leap-nvim
      mkdir-nvim
      nvim-autopairs
      neoscroll-nvim
      vim-pasta
      markdown-preview-nvim
      compiler-nvim

      telescope-nvim
      telescope-live-grep-args-nvim
      telescope-fzf-native-nvim
      telescope-emoji-nvim
      external.telescope-heading
      external.tailiscope
      external.browser-bookmarks
      external.github-coauthors

      harpoon2
      auto-save-nvim
      zen-mode-nvim
      thesaurus_query-vim
      easy-dotnet-nvim
      nvim-dap
      dressing-nvim
      overseer-nvim
      codecompanion-nvim
    ]
