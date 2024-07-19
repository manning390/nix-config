{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    theme = "Nord";
    font = {
      name = "Fira Code";
      size = 14;
    };

    # consistent with wezterm
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # search in the current window
    };

    # Unsure if still need
    # # Map over legacy compatability by sending the CSI escape code from
    # # kitty +kitten show_key -m kitty
    # #
    # # \x1b\x5b key ; mod u
    # #
    # # \x1b\x5b is 'CSI' escape seq
    # # key & mod from show_key
    # # u is termination
    # map ctrl+m send_text all \x1b\x5b109;133u
    # map ctrl+i send_text all \x1b\x5b105;133u
    # map ctrl+shift+h send_text all \x1b\x5b104;134u

    settings = {
      background_opacity = "0.93";
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      enable_audio_bell = false;
      tab_bar_edge = "top"; # tab bar on top
    };

    # macOS specific settings
    darwinLaunchOptions = ["--start-as=maximized"];
  }
}
