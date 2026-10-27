# Highlight and search TODO-style comments; load when opening or creating a buffer.
{
  local.nvim.plugins.todo-comments = {
    package = "todo-comments-nvim";
    lua =
      # lua
      ''
        {
          "todo-comments.nvim",
          event = { "BufReadPost", "BufNewFile" },
          main = "todo-comments",
          opts = {},
        }
      '';
  };
}
