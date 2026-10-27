# Navigate seamlessly between Neovim windows and tmux panes.
# Load before custom mappings so plugin defaults cannot override Colemak bindings.
{
  local.nvim.plugins.tmux-navigator = {
    package = "vim-tmux-navigator";
    # Load before config.keymaps so its defaults cannot overwrite Colemak bindings.
    lua =
      # lua
      ''{ "vim-tmux-navigator", lazy = false }'';
  };
}
