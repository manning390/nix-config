{}:{}
# {
#   pkgs,
#   lib,
#   inputs,
#   ...
# }: let
#   inherit (inputs.nixpkgs) legacyPackages;
# in rec {
#
#   mkVimPlugin = {system}: let
#     inherit (pkgs) vimUtils;
#     inhert (vimUtils) vuildVimPlugin;
#     pkgs = legacyPackages.${system};
#   in
#     buildVimPlugin {
#       name = "manning390-nvim";
#       postInstall = ''
#         rm -rf $out/.envrc
#         rm -rf $out/.gitignoree
#         rm -rf $out/LICENSE
#         rm -rf $out/README.md
#         rm -rf $out/flake.lock
#         rm -rf $out/flake.nix
#         rm -rf $out/justfile
#         rm -rf $out/lib
#       '';
#       src = ../.;
#     };
#
#   mkNeovimPlugins = {system}: let
#     inherit (pkgs) vimPlugins;
#     pkgs = legacyPackages.${system};
#     manning390-nvim = mkVimPlugin {inherit system;};
#   in [
#
#   # LSP
#   nvim-lspconfig # LSP
#   nvim-treesitter.withAllGrammars
#   neodev # Additional lua LSP info
#   vim-just
#   typescript-tools-nvim
#   phpactor
#
#   # Lsp Utilities
#   trouble-nvim
#   conform-nvim
#   nvim-notify
#
#   laravel
#   # deps
#   none-ls-nvim
#   nui-nvim
#   vim-dotenv
#
#   # Snippets
#   luasnip
#
#   # Completion
#   nvim-cmp
#   cmp-buffer
#   #cmp-calc
#   cmp-nvim-lsp
#   cmp-nvim-lua
#   cmp-path
#   #cmp-emmet-vim
#   #emmet-vim
#   cmp_luasnip
#
#   # Git
#   vim-fugitive
#   vim-rhubarb
#   gitsigns-nvim
#
#   # Theme
#   lualine-nvim
#   nvim-web-devicons
#   nord-nvim
#
#   # Telescope
#   plenary-nvim
#   telescope-nvim
#   telescope-live-grep-args-nvim
#   telescope-fzf-native-nvim
#   tailiscope-nvim
#   telescope-heading-nvim
#   browser-bookmarks-nvim
#   github-coauthors-nvim
#
#   # Harpoon
#   harpoon2
#
#   # Utils
#   vim-tmux-navigator
#   git-worktree-nvim
#   refactoring-nvim
#   indent-blankline-nvim
#   comment-nvim
#   vim-abolish
#   vim-eunuch
#   vim-repeat
#   nvim-surround
#   vim-unimpaired
#   todo-comments-nvim
#   leap-nvim
#   mkdir-nvim
#   neoscroll-nvim
#   vim-pasta
#
#   # Testing
#   nvim-test
#
#   # Writing
#   auto-save-nvim
#   twilight-nvim
#   zen-mode-nvim
#   #thesaurus_query-vim
#   wrd-nvim
# ];
#
#
#   programs.neovim = {
#     # enable = true;
#
#     defaultEditor = true;
#
#     viAlias = true;
#     vimAlias = true;
#     vimdiffAlias = true;
#
#     plugins = with pkgs.vimPlugins; [
#     ];
#   };
#
#   home.sessionVariables = {
#     COLEMAK = "$(lsusb | grep -c 'Ergo')";
#   };
# }
