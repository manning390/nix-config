{
  local.nvim.plugins.tmux-navigator = {
    package = "vim-tmux-navigator";
    # Load before config.keymaps so its defaults cannot overwrite Colemak bindings.
    lua =
      # lua
      ''{ "vim-tmux-navigator", lazy = false }'';
  };
}
