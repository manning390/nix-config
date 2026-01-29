{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./waybar
    ./hyprpanel
    ./hyprpaper
    ./caelestia
  ];

  # Set defaults for our wm modules
  custom.wm = {
    waybar.enable = lib.mkDefault false;
    hyprpanel.enable = lib.mkDefault false;
    caelestia.enable = lib.mkDefault true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      exec-once = [
        "app2unit -s b wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        "app2unit -s b udiskie --smart-stray"
      ];
      input = lib.mkMerge [
        (lib.mkIf osConfig.custom.colemak_dhm.enable {
          kb_layout = "colemak_dhm,us";
          kb_options = "caps:escape,grp:alt_shift_toggle";
        })
        (lib.mkIf (!osConfig.custom.colemak_dhm.enable) {
          kb_options = "caps:escape";
        })
      ];
      monitor = [
        "DP-1,2560x1440@144,2560x0,1"
        "HDMI-A-1,2560x1440@144,0x0,1"
        "HDMI-A-2,2560x1440@144,5120x0,1"
      ];
      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,24"
      ];

      "$mod" = "SUPER";
      bind =
        [
          "$mod, RETURN, exec, app2unit -s a kitty"
          "$mod, C, killactive"
          "ALT, F4, exec, hyprctl kill"
          "$mod SHIFT, Q, exit"
          "$mod, V, togglefloating"
          # "$mod, D, exec, uwsm app -- rofi -show drun -show-icons"
          "$mod, D, global, caelestia:launcher"
          
          "$mod, P, pseudo"
          "$mod, T, togglesplit"
          "$mod, F, fullscreen"
          "$mod, TAB, focuscurrentorlast"
          # "$mod, L, exec, hyprlock"
          "$mod, L, global, caelestia:lock"
          "$mod, A, global, caelestia:picker open"
          # Screen shots
          ", Print, exec, app2unit -s a grimblast --notify copy area"
          "SHIFT, Print, exec, app2unit -s a grimblast --notify copysave area"
          # Volume keys
          # Media keys
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
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
              l = {
                arrow = "left";
                vi = "M";
              };
              r = {
                arrow = "right";
                vi = "I";
              };
              u = {
                arrow = "up";
                vi = "E";
              };
              d = {
                arrow = "down";
                vi = "N";
              };
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
      bindel = [
        # Volume controls
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # Brightness
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ];
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
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
        # blur = {
        #   enabled = true;
        #   size = 3;
        #   passes = 1;
        # };
        shadow = {
          enabled = true;
          color = lib.mkDefault "rgba(1a1a1aee)";
        };
      };
      # animations = {
      #   enabled = "yes";
      #   bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      #   animation = [
      #     "windows, 1, 7, myBezier"
      #     "windowsOut, 1, 7, default, popin 80%"
      #     "border, 1, 10, default"
      #     "borderangle, 1, 8, default"
      #     "fade, 1, 7, default"
      #     "workspaces, 1, 6, default"
      #   ];
      # };
      misc.force_default_wallpaper = 0;
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };
      windowrulev2 = [
        #   "float,class:^(kvantummanager)$"
        #   "float,class:^(qt5ct)$"
        #   "float,class:^(qt6ct)$"
        "float,class:^(nwg-look)$"
        #   "float,class:^(org.kde.ark)$"
        "float,class:^(pavucontrol)$"
        #   "float,class:^(blueman-manager)$"
        #   "float,class:^(nm-applet)$"
        #   "float,class:^(nm-connection-editor)$"
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };

  # home.file.".config/hypr/hypridle.conf".text = builtins.readFile ./hypridle.conf;
  # home.file.".config/hypr/hyprlock.conf".text = builtins.readFile ./hyprlock.conf;

  # Hint electron to use wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 20;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
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

  home.file.".config/uwsm/env".text = ''
    export GTK_BACKEND=wayland,x11,*
    export QT_QPA_PLATFORM=wayland;xcb
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
    export XCURSOR_THEME=Bibata-Modern-Classic
    export XCURSOR_SIZE=20
    export WAYLAND_DISPLAY=wayland-1
    export APP2UNIT_SLICES='a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice'
    export APP2UNIT_TYPE=scope
  '';
}
