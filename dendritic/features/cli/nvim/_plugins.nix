{
  inputs,
  pkgs,
  externalPlugins,
  ...
}: let
  plug = pkg: {plugin = pkg;};
  plugCfg = pkg: lua: {
    plugin = pkg;
    config = lua;
    type = "lua";
  };
  external =
    externalPlugins
    |> builtins.listToAttrs
    |> (map (name: {
      inherit name;
      value = pkgs.vimUtils.buildVimPlugin {
        inherit name;
        src = inputs.${name};
      };
    }));
in
  with pkgs.vimPlugins; [
    lze

    # Treesitter — keep withAllGrammars, config stays in after/plugin/treesitter.lua
    nvim-treesitter.withAllGrammars
    nvim-ts-context-commentstring
    nvim-treesitter-textobjects

    # LSP — config in after/plugin/lsp.lua
    (plug nvim-lspconfig)
    (plug efmls-configs-nvim)
    (plug typescript-tools-nvim)
    (plug none-ls-nvim)
    (plugCfg phpactor
      #lua
      ''require("phpactor").setup({ install = { check_on_startup = "none" }, lspconfig = { enabled = false } })'')

    # Formatting
    (plug conform-nvim) # config in plugins/lsp.lua

    # Notifications — config in lua/config/notify.lua (unchanged)
    (plug nvim-notify)

    # Snippets
    (plug luasnip)

    # Completion — config in after/plugin/cmp.lua (unchanged)
    (plug nvim-cmp)
    (plug cmp-buffer)
    (plug cmp-calc)
    (plug cmp-spell)
    (plug cmp-git)
    (plug cmp-nvim-lua)
    (plug cmp-path)
    (plug cmp_luasnip)
    (plug cmp-async-path)
    (plug cmp-nvim-lsp-signature-help)
    (plug external.cmp-async-path)
    (plug lspkind-nvim)

    # Tmux
    (plug vim-tmux-navigator)

    # Git — config in plugins/git.lua
    (plug vim-fugitive)
    (plug vim-rhubarb)
    (plugCfg gitsigns-nvim "require('gitsigns').setup()")
    (plug vim-speeddating)
    (plug git-worktree-nvim)
    (plug refactoring-nvim)

    # Theme — config in after/plugin/color.lua (unchanged)
    (plugCfg nord-nvim "vim.cmd([[colorscheme nord]])")
    (plugCfg lualine-nvim "") # config in after/plugin/lualine.lua
    (plug nvim-web-devicons)

    # Utils
    (plugCfg indent-blankline-nvim
      #lua
      ''require("ibl").setup({ scope = { enabled = false } })'')
    (plugCfg comment-nvim "require('Comment').setup()")
    (plug treesj) # config in after/plugin/treesj.lua
    (plug vim-abolish)
    (plug vim-eunuch)
    (plug vim-repeat)
    (plug vim-sleuth)
    (plug vim-unimpaired)
    (plugCfg nvim-surround "require('nvim-surround').setup()")
    (plugCfg align-nvim "")
    (plugCfg todo-comments-nvim "require('todo-comments').setup()")
    (plugCfg leap-nvim "require('leap').create_default_mappings()")
    (plug mkdir-nvim)
    (plugCfg nvim-autopairs "require('nvim-autopairs').setup({ fast_wrap = {} })")
    (plugCfg neoscroll-nvim "require('neoscroll').setup()")
    (plugCfg vim-pasta "vim.g.pasta_disabled_filetypes = { 'fugitive' }")
    (plugCfg markdown-preview-nvim "")
    (plug trouble-nvim)
    (plug compiler-nvim)

    # Telescope — config in lua/config/telescope.lua (unchanged)
    (plug telescope-nvim)
    (plug telescope-live-grep-args-nvim)
    (plug telescope-fzf-native-nvim)
    (plug external.telescope-heading)
    (plug external.telescope-emoji)
    (plug external.tailiscope)
    (plug external.tailwind-fold)

    # Navigation
    (plug harpoon2)

    # Writing
    (plug auto-save-nvim)
    (plug zen-mode-nvim)
    (plug twilight-nvim)

    # Dotnet
    (plug easy-dotnet-nvim)
    (plug nvim-dap)
    (plug dressing-nvim)
    (plug overseer-nvim)

    # Copilot
    (plug codecompanion-nvim)
    # (plug copilot-lua)
    # (plug CopilotChat-nvim)
  ]
