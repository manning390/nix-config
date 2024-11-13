{
  pkgs,
  lib,
  ...
}: {
  programs.kitty = {
    enable = true;
    theme = "Nord";
    font = {
      name = lib.mkDefault "Fira Code Nerd Font";
      package = lib.mkDefault pkgs.fira-code-nerdfont;
      size = lib.mkDefault 14;
    };

    settings = {
    };

    keybindings = {
      # Map over legacy compatability by sending the CSI escape code from
      # kitty +kitten show_key -m kitty
      #
      # \x1b\x5b key ; mod u
      #
      # \x1b\x5b is 'CSI' escape seq
      # key & mod from show_key
      # u is termination
      "ctrl+m" = "send_text all \x1b\x5b109;133u";
      "ctrl+i" = "send_text all \x1b\x5b105;133u";
      "ctrl+shift+h" = "send_text all \x1b\x5b104;134u";
    };
  };

  home.sessionVariables = {
    TERM = "kitty";
  };
}
