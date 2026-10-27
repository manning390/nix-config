# Distraction-free writing layout with terminal and Git-sign integrations.
# Load only when :ZenMode is invoked.
{
  local.nvim.plugins.zen-mode = {
    package = "zen-mode-nvim";
    lua =
      # lua
      ''
        {
          "zen-mode.nvim",
          cmd = "ZenMode",
          main = "zen-mode",
          opts = {
            window = {
              width = 80,
              options = {
                wrap = true,
                linebreak = true,
                breakindent = false,
                breakindentopt = "",
                sidescroll = 0,
                showbreak = "",
                list = false,
                number = false,
                relativenumber = false,
                colorcolumn = "",
              },
            },
            gitsigns = { enabled = true },
            tmux = { enabled = true },
            kitty = { enabled = true },
            wezterm = { enabled = true },
          },
        }
      '';
  };
}
