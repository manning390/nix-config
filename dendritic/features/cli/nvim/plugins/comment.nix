# Toggle line and block comments with language-aware comment strings.
# Install default mappings after the UI starts.
{
  local.nvim.plugins.comment = {
    package = "comment-nvim";
    lua =
      # lua
      ''
        { "comment.nvim", event = "DeferredUIEnter", main = "Comment", opts = {} }
      '';
  };
}
