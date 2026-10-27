# Detect indentation settings from file contents and nearby files.
# Register detection hooks at startup for the first opened buffer.
{
  local.nvim.plugins.sleuth = {
    package = "vim-sleuth";
    optional = false;
  };
}
