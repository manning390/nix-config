local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_domain = "WSL:NixOS"
config.wsl_domains = {{
  name = 'WSL:NixOS',
  distribution = "NixOS"
}}

config.font = wezterm.font 'FiraCode Nerd Font'
config.enable_csi_u_key_encoding = false
config.enable_kitty_keyboard = false
config.window_close_confirmation = 'NeverPrompt'

config.canonicalize_pasted_newlines = "LineFeed"

config.color_scheme = 'nord'
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = '#4c566a',
      fg_color = '#eceff4'
    }
  }
}

config.keys = {
  {
    key = "m",
    mods = "CTRL",
    action = wezterm.action.SendString('\x1b\x5b109;133u')
  },
  {
    key = "i",
    mods = "CTRL",
    action = wezterm.action.SendString('\x1b\x5b105;133u')
  },
  {
    key = "h",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString('\x1b\x5b104;134u')
  },
  {
    key = "~",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_window()
    end),
  },
}

return config
