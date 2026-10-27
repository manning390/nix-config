# Insert matching brackets and quotes; load on entering Insert mode or completion setup.
{
  local.nvim.plugins.autopairs = {
    package = "nvim-autopairs";
    lua =
      # lua
      ''
        {
          "nvim-autopairs",
          event = "InsertEnter",
          on_require = "nvim-autopairs",
          main = "nvim-autopairs",
          opts = { fast_wrap = {} },
        }
      '';
  };
}
