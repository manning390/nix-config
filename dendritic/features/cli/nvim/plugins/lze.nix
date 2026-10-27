# Trigger-based plugin loader for commands, events, filetypes, and Lua requires.
# Must be available at startup to register all other plugin specifications.
{
  local.nvim.plugins.lze = {
    package = "lze";
    optional = false;
  };
}
