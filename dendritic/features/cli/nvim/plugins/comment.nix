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
