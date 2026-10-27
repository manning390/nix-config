# Automatically create missing parent directories when saving files.
# Register write hooks at startup so the first save is covered.
{
  local.nvim.plugins.mkdir = {
    package = "mkdir-nvim";
    optional = false;
  };
}
