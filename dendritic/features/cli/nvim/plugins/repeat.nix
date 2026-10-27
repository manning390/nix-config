# Extend dot-repeat to compatible plugin actions.
# Keep autoload support available before the first repeatable action.
{
  local.nvim.plugins.repeat = {
    package = "vim-repeat";
    optional = false;
  };
}
