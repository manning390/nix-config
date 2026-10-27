# Manage build/run tasks and their output; load through commands or Compiler integration.
{
  local.nvim.plugins.overseer = {
    package = "overseer-nvim";
    lua =
      # lua
      ''
        {
          "overseer.nvim",
          on_require = "overseer",
          cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerClose" },
          dep_of = "compiler.nvim",
          main = "overseer",
          opts = {
            task_list = {
              direction = "bottom",
              min_height = 25,
              max_height = 25,
              default_detail = 1,
            },
          },
        }
      '';
  };
}
