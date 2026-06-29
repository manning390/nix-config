{
  flake-file.inputs.hyprland-contrib.url = "github:hyprwm/contrib";
  flake.aspects = {aspects, ...}: {
    hyprland = {
      description = "The wayland desktop compositor";
      includes = with aspects; [gtk];

      nixos = {
        inputs,
        config,
        lib,
        pkgs,
        ...
      }: let
        userShell = config.local.shells.userShell;
      in {
        options.local.wm.hyprland = {
          layout = lib.mkOption {
            type = lib.types.enum ["dwindle" "scrolling" "master"];
            default = "dwindle";
            example = "scrolling";
          };
        };
        config = {
          programs.hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
            portalPackage = pkgs.xdg-desktop-portal;
          };

          environment.systemPackages = with pkgs; [
            app2unit # similar to UWSM, daemon launcher, faster
            # hyprlock # lock screen
            hyprcursor # Better cursors
            hypridle # System idle
            hyprpicker # Color picker
            unstable.hyprpolkitagent # Escalate priviledges
            playerctl
            brightnessctl
            mako
            libnotify
            wl-clipboard-rs
            inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
          ];

          xdg.portal = {
            enable = true;
            extraPortals = [pkgs.xdg-desktop-portal-hyprland];
          };

          programs.${userShell}.interactiveShellInit = ''
            if uwsm check may-start; then
              exec uwsm start hyprland-uwsm.desktop
            fi
          '';
        };
      };

      homeManager = {
        pkgs,
        lib,
        osConfig,
        ...
      }: {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = true;
          configType = "hyprlang";
          settings = {
            exec-once = [
              # "app2unit -s b wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
              "app2unit -s b udiskie --smart-stray"
            ];

            device = [
              {
                name = "at-translated-set-2-keyboard";
                kb_layout = "colemak_dhm,us";
                kb_options = "caps:escape,grp:alt_shift_toggle";
              }
              {
                name = "zsa-technology-labs-voyager-keyboard";
                kb_layout = "us";
              }
            ];

            # monitor = [
            #   "DP-1,2560x1440@144,2560x0,1"
            #   "HDMI-A-1,2560x1440@144,0x0,1"
            #   "HDMI-A-2,2560x1440@144,5120x0,1"
            # ];
            monitor = lib.mapAttrsToList (name: value: "${name},${value}") osConfig.local.hardware.monitors;
            env = [
              "HYPRCURSOR_THEME,rose-pine-hyprcursor"
              "HYPRCURSOR_SIZE,24"
            ];

            "$mod" = "SUPER";
            bind = let
              cfg = osConfig.local.wm.hyprland;
              directions = {
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
              };
              dwindleBinds = builtins.concatLists (builtins.attrValues (
                builtins.mapAttrs (dir: keys: [
                  "$mod, ${keys.arrow}, movefocus, ${dir}"
                  "$mod, ${keys.vi}, movefocus, ${dir}"
                  "$mod SHIFT, ${keys.arrow}, movewindow, ${dir}"
                  "$mod SHIFT, ${keys.vi}, movewindow, ${dir}"
                  "$mod, T, layoutmsg, togglesplit"
                ])
                directions
              ));
              scrollingBinds = [
                "$mod, ${directions.l.vi}, layoutmsg, focus, l"
                "$mod, ${directions.r.vi}, layoutmsg, focus, r"
                "$mod, ${directions.u.vi}, layoutmsg, focus, u"
                "$mod, ${directions.d.vi}, layoutmsg, focus, d"

                "$mod SHIFT, ${directions.l.vi}, layoutmsg, swapcol, l"
                "$mod SHIFT, ${directions.r.vi}, layoutmsg, swapcol, r"
                "$mod SHIFT, ${directions.d.vi}, layoutmsg, movewindow, d"
                "$mod SHIFT, ${directions.u.vi}, layoutmsg, movewindow, u"

                # "$mod ${directions.d.arrow}, layoutmsg, consume"
                # "$mod ${directions.u.arrow}, layoutmsg, expel"
                "$mod SHIFT, ${directions.u.arrow}, layoutmsg, colresize, +conf"
                "$mod SHIFT, ${directions.d.arrow}, layoutmsg, colresize, -conf"
              ];
              # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
              workspaceBinds = builtins.concatLists (builtins.genList (
                  x: let
                    ws = let
                      c = (x + 1) / 10;
                    in
                      toString (x + 1 - (c * 10));
                  in [
                    "$mod, ${ws}, workspace, ${toString (x + 1)}"
                    "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                  ]
                )
                10);
            in
              [
                "$mod, RETURN, exec, app2unit -s a kitty"
                "$mod, C, killactive"
                "ALT, F4, exec, hyprctl kill"
                "$mod SHIFT, Q, exit"
                "$mod, V, togglefloating"
                # "$mod, D, exec, uwsm app -- rofi -show drun -show-icons"
                "$mod, D, global, caelestia:launcher"

                "$mod, P, pseudo"
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
              ++ (
                if cfg.layout == "dwindle"
                then dwindleBinds
                else []
              )
              ++ (
                if cfg.layout == "scrolling"
                then scrollingBinds
                else []
              )
              ++ workspaceBinds;
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
              layout = osConfig.local.wm.hyprland.layout;
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

            misc.force_default_wallpaper = 0;
            dwindle = {
              preserve_split = true;
            };
            scrolling = {
            };
            windowrule = [
              "float on, match:class ^(nwg-look)$"
              "float on, match:class ^(pavucontrol)$"
              "opacity 0.0 0.0 override, match:class ^(xwaylandvideobridge)$"
              "no_anim on, match:class ^(xwaylandvideobridge)$"
              "max_size 1 1, match:class ^(xwaylandvideobridge)$"
              "no_blur on, match:class ^(xwaylandvideobridge)$"
              "no_focus on, match:class ^(xwaylandvideobridge)$"
              "float on, match:class ^(XIVLauncher.*)$"
              "float on, match:class ^(1password)$"
              "border_size 0, match:initial_title ^(FINAL FANTASY XIV)$"
            ];
          };
        };

        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.unstable.catppuccin-cursors.mochaDark;
          name = "catppuccin-mocha-dark-cursors";
          size = 20;
        };

        # Hint electron to use wayland
        home.sessionVariables.NIXOS_OZONE_WL = "1";

        home.file.".config/uwsm/env".text =
          /*
          bash
          */
          ''
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
      };
    };
  };
}
