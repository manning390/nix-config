{
  local.nvim.plugins.refactoring = {
    package = "refactoring-nvim";
    lua =
      # lua
      ''
        {
          "refactoring.nvim",
          cmd = "Refactor",
          on_require = "refactoring",
          main = "refactoring",
          opts = {},
        }
      '';
  };
}
