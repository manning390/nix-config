# Shared Lua utilities for jobs, paths, async work, and testing.
# Keep modules available on the runtime path for dependent plugins.
{
  local.nvim.plugins.plenary = {
    package = "plenary-nvim";
    optional = false;
  };
}
