# Extract and inline variables, functions, and blocks.
# Load through :Refactor or the refactoring picker mapping.
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
