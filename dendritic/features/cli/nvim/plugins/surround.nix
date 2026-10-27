# Add, change, and delete surrounding quotes, brackets, and tags.
# Install editing mappings after the UI starts.
{
  local.nvim.plugins.surround = {
    package = "nvim-surround";
    lua =
      # lua
      ''
        {
          "nvim-surround",
          event = "DeferredUIEnter",
          main = "nvim-surround",
          opts = {},
        }
      '';
  };
}
