# Git commands, status buffers, and diff workflows; load through Git commands.
{
  local.nvim.plugins.fugitive = {
    package = "vim-fugitive";
    lua =
      # lua
      ''
        {
          "vim-fugitive",
          cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gread", "Gwrite", "GBrowse" },
        }
      '';
  };
}
