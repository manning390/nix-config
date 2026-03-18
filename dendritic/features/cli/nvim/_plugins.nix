# This list of plugins gets exposed for lazy to use
# linking from nix store rather than installing imperatively
{pkgs,...}: with pkgs.vimPlugins; [
    lazy-nvim
    nvim-treesitter.withAllGrammars
    nvim-lspconfig
    efmls-configs-nvim
    typecript-tools-nvim
    none-ls-nvim
    compiler-nvim
    phpactor
    markdown-preview-nvim
    trouble-nvim
    conform-nvim
    nvim-notify
    luasnip
    nvim-cmp
    cmp-buffer
    cmp-calc
    cmp-spell
    cmp-git
    cmp-nvim-lua
    cmp-vim-lsp
    cmp-path
    cmp_luasnip
    cmp-async-path
    cmp-nvim-lsp-signature-help
    cmp-nvim-lsp-document-help
    emmet-vim
    lspkind-nvim
    nvim-treesitter
    nvim-ts-context-commentstring
    nvim-treesitter-textobjects
    vim-tmux-navigator
    vim-speeddating
    vim-fugitive
    vim-rhubarb
    gitsigns-nvim
    lualine-nvim
    nvim-web-devicons
    nord-nvim
    indent-blankline-nvim
    comment-nvim
    treesj
    vim-abolish
    vim-eunuch
    vim-repeat
    vim-sleuth
    vim-unimpaired
    nvim-surround
    leap-nvim
    align-nvim
    todo-comments-nvim
    # color-converter
    mkdir-nvim
    neoscroll-nvim
    vim-pasta
    telescope-nvim
    telescope-live-grep-args-nvim
    telescope-fzf-native-nvim
    # tailiscope
    telescope-heading
    # browser-bookmarks
    # github-coauthors
    harpoon2
    git-worktree-nvim
    refactoring-nvim
    nvim-test
    overseer-nvim
    dressing-nvim
    easy-dotnet-nvim
    nvim-dap

    # Writing
    auto-save-nvim
    zen-mode-nvim
    twilight-nvim
]
