{
  pkgs,
  lib,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      # "kitty-keyboard-protocol" = "yes"; # Suppose to turn on the kitty-keyboard-protocol for keybindings
      # These don't work at the moment, figure out what's wrong. 
      key-bindings = {
        "Control+Shift+H" = "send-text:\\x1b\\x5b104;134u";
        "Control+I" = "send-text:\\x1b\\x5b105;133u";
        "Control+M" = "send-text:\\x1b\\x5b109;133u";
      };
    };
  };
}
