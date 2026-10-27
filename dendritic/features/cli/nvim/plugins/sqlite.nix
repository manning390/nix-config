# Lua SQLite bindings used to read Firefox bookmark databases.
# Keep modules on the runtime path; SQLite loads when a consumer requires it.
{
  local.nvim.plugins.sqlite = {
    package = "sqlite-lua";
    optional = false;
  };
}
