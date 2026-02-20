{
  flake.aspects.kitty = {
    nixos = {lib, ...}: {
      options.local.term.kitty = lib.mkEnableOptions "Enables Kitty Terminal";
    };
    homeManager = {config, lib, ...}: lib.mkIf config.local.term.kitty.enable ({pkgs, ...}: {
      programs.kitty = {
        enable = true;
        themeFile = "Nord";
        font = {
          name = lib.mkDefault "FiraCode Nerd Font";
          package = lib.mkDefault pkgs.nerd-fonts.fira-code;
          size = lib.mkDefault 14;
        };

        settings = {
          cursor_trail = 1;
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
          "ctrl+m" = "send_text all \\x1b\\x5b109;133u";
          "ctrl+i" = "send_text all \\x1b\\x5b105;133u";
          "ctrl+shift+h" = "send_text all \\x1b\\x5b104;134u";
        };
      };

      home.sessionVariables = {
        TERM = "kitty";
        KITTY_ENABLE_WAYLAND = "1";
      };
    });
  };
}
