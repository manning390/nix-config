{
  local.nvim.plugins.dap = {
    package = "nvim-dap";
    lua =
      # lua
      ''{ "nvim-dap", on_require = "dap" }'';
  };
}
