# Display indentation guides; load when opening or creating a buffer.
{
  local.nvim.plugins.indent-blankline = {
    package = "indent-blankline-nvim";
    lua =
      # lua
      ''
        {
          "indent-blankline.nvim",
          event = { "BufReadPost", "BufNewFile" },
          main = "ibl",
          opts = { scope = { enabled = false } },
        }
      '';
  };
}
