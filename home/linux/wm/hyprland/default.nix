{
  lib,
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      exec-once = lib.strings.concatStringsSep "& " [
        "hyprctl setcursor Bibata-Modern-Classic 20"
        "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      monitor = [
        "HDMI-A-1,2560x1440@144,0x0,1"
        "DP-1,2560x1440@144,2560x0,1"
        "HDMI-A-2,2560x1440@144,5120x0,1"
      ];
      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,20"
        # "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        # "HYPRCURSOR_SIZE,24"
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
          "$mod, T, togglesplit"
          "$mod, F, fullscreen"
          "$mod, TAB, focuscurrentorlast"
          # Screen shots
          ", Print, exec, grimblast --notify copy area"
          "SHIFT, Print, exec, grimblast --notify copysave area"
        ]
        ++ (builtins.concatLists (
          builtins.attrValues (
            builtins.mapAttrs (direction: keys: [
              "$mod, ${keys.arrow}, movefocus, ${direction}"
              "$mod, ${keys.vi}, movefocus, ${direction}"
              "$mod SHIFT, ${keys.arrow}, movewindow, ${direction}"
              "$mod SHIFT, ${keys.vi}, movewindow, ${direction}"
            ])
            {
              l = { arrow = "left"; vi = "M"; };
              r = { arrow = "right"; vi = "I"; };
              u = { arrow = "up"; vi = "E"; };
              d = { arrow = "down"; vi = "N"; };
            }
          )
        ))
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
        "$mod, mouse:273, resizewindow" # right click with mod to resize
        "$mod ALT, mouse:272, resizewindow" # left click with mod + alt to resize
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
        shadow = {
          enabled = true;
          color = lib.mkDefault "rgba(1a1a1aee)";
        };
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
      windowrulev2 = [
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
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };
  # Hint electron to use wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    KITTY_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland discord-canary";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 20;
    };
  };

  # Install cursor theme
  # home.file.".local/share/icons/nordzy-cursors" = {
  #   recursive = true;
  #   source = "${inputs.nordzy-hyprcursors}/themes/Nordzy-cursors";
  # };
  # home.file.".local/share/icons/nordzy-hyprcursors" = {
  #   recursive = true;
  #   source = "${inputs.nordzy-hyprcursors}/hyprcursors/themes/Nordzy-hyprcursors";
  # };

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

  # programs.zsh = {
  #   enable = true;
  #   initExtra = ''
  #     if uwsm check may-start; then
  #       exec uwsm start hyprland.desktop
  #     fi
  #   '';
  # };
}
