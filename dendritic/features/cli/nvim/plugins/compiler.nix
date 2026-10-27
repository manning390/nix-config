# Build/run picker backed by Telescope and Overseer; load through compiler commands.
{
  local.nvim.plugins.compiler = {
    package = "compiler-nvim";
    lua =
      # lua
      ''
        {
          "compiler.nvim",
          cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
          before = function()
            require("lze").trigger_load("telescope.nvim")
          end,
          main = "compiler",
          opts = {},
        }
      '';
  };
}
