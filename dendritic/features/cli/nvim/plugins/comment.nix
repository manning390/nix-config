{
  local.nvim.plugins.comment = {
    package = "comment-nvim";
    lua =
      # lua
      ''
        { "comment.nvim", main = "Comment", opts = {} }
      '';
  };
}
