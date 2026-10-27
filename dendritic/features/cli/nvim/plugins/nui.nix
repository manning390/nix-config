# Shared Lua UI primitives used by other plugins.
# Keep the library on the runtime path; consumers require its modules as needed.
{
  local.nvim.plugins.nui = {
    package = "nui-nvim";
    optional = false;
  };
}
