# Improve vim.ui input and selection dialogs; initialize after the UI starts.
{
  local.nvim.plugins.dressing = {
    package = "dressing-nvim";
    lua =
      # lua
      ''
        {
          "dressing.nvim",
          on_require = "dressing",
          event = "DeferredUIEnter",
          main = "dressing",
          opts = {},
        }
      '';
  };
}
