# Reindent pasted text to match its destination.
# Install paste mappings after the UI starts, excluding Fugitive buffers.
{
  local.nvim.plugins.pasta = {
    package = "vim-pasta";
    lua =
      # lua
      ''
        {
          "vim-pasta",
          event = "DeferredUIEnter",
          beforeAll = function()
            vim.g.pasta_disabled_filetypes = { "fugitive" }
          end,
        }
      '';
  };
}
