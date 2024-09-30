{
  lib,
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      exec-once = lib.strings.concatStringsSep "& " [
        "waybar"
        "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
      ];
      monitor = [
        "HDMI-A-1,2560x1440@144,0x0,1"
        "DP-1,2560x1440@144,2560x0,1"
        "HDMI-A-2,2560x1440@144,5120x0,1"
      ];
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Nordzy-cursors"
        "HYPRCURSOR_THEME,Nordzy-cursors"
        "HYPRCURSOR_SIZE,24"
      ];

      "$mod" = "SUPER";
      bind =
        [
          "$mod, RETURN, exec, $TERM"
          "$mod, C, killactive"
          "$mod SHIFT, Q, exit"
          "$mod, V, togglefloating"
          "$mod, D, exec, rofi -show drun -show-icons"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"
          "$mod, left,  movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up,    movefocus, u"
          "$mod, down,  movefocus, d"
          "$mod, M, movefocus, l"
          "$mod, I, movefocus, r"
          "$mod, E, movefocus, u"
          "$mod, N, movefocus, d"
          "$mod, F, fullscreen"
          # Screen shots
          ", Print, exec, grimblast --notify copy area"
          "SHIFT, Print, exec, grimblast --notify copysave area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkDefault "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = lib.mkDefault "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = lib.mkDefault "rgba(1a1a1aee)";
      };
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      misc.force_default_wallpaper = 0;
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };
      # windowrulev2 = [
      #   "float,class:^(kvantummanager)$"
      #   "float,class:^(qt5ct)$"
      #   "float,class:^(qt6ct)$"
      #   "float,class:^(nwg-look)$"
      #   "float,class:^(org.kde.ark)$"
      #   "float,class:^(pavucontrol)$"
      #   "float,class:^(blueman-manager)$"
      #   "float,class:^(nm-applet)$"
      #   "float,class:^(nm-connection-editor)$"
      #   "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
      # ];
    };
  };
  # Hint electron to use wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    KITTY_ENABLE_WAYLAND = "1";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
  };

  # Install cursor theme
  home.file.".local/share/icons/nordzy-cursors" = {
    recursive = true;
    source = "${inputs.nordzy-hyprcursors}/themes/Nordzy-cursors";
  };
  home.file.".local/share/icons/nordzy-hyprcursors" = {
    recursive = true;
    source = "${inputs.nordzy-hyprcursors}/hyprcursors/themes/Nordzy-hyprcursors";
  };

  xdg.configFile."waybar" = {
    recursive = true;
    source = ./waybar;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/pictures/wallpapers/windows-panic.png"
        "~/pictures/wallpapers/nixos.png"
        "~/pictures/wallpapers/pixelmoon.png"
      ];
      wallpaper = [
        "HDMI-A-1,~/pictures/wallpapers/windows-panic.png"
        "DP-1,~/pictures/wallpapers/nixos.png"
        "HDMI-A-2,~/pictures/wallpapers/pixelmoon.png"
      ];
      splash = true;
    };
  };
}
