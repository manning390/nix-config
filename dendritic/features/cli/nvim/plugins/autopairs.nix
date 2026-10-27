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
