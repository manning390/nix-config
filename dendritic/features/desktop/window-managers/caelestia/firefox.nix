{
  flake.modules.nixos.caelestia-firefox = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.local.desktop.caelestia.firefox;
    helper = pkgs.writeShellApplication {
      name = "caelestiafox";
      runtimeInputs = with pkgs; [fish jq inotify-tools coreutils];
      text = ''
        exec fish ${./_caelestiafox.fish}
      '';
    };
    manifest = pkgs.writeText "caelestiafox.json" (builtins.toJSON {
      name = "caelestiafox";
      description = "Read Caelestia's local colour scheme for CaelestiaFox.";
      path = "${helper}/bin/caelestiafox";
      type = "stdio";
      allowed_extensions = ["caelestiafox@caelestia.org"];
    });
    nativeHost = pkgs.runCommand "caelestiafox-native-host" {} ''
      install -Dm644 ${manifest} "$out/lib/mozilla/native-messaging-hosts/caelestiafox.json"
    '';
  in {
    options.local.desktop.caelestia.firefox = {
      enable = lib.mkEnableOption "live Firefox colour theming with CaelestiaFox";
      browserLayout.enable =
        lib.mkEnableOption "Caelestia browser layout CSS for Home Manager-managed Firefox profiles";
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.programs.firefox.enable;
          message = "Caelestia Firefox integration requires programs.firefox.enable.";
        }
      ];

      programs.firefox = {
        nativeMessagingHosts.packages = [nativeHost];
        policies.ExtensionSettings."caelestiafox@caelestia.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/caelestiafox/latest.xpi";
        };
      };
    };
  };

  flake.modules.homeManager.caelestia-firefox = {
    lib,
    osConfig,
    ...
  }: {
    # Extend each declared profile without creating/replacing any profiles.
    options.programs.firefox.profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        config = lib.mkIf osConfig.local.desktop.caelestia.firefox.browserLayout.enable {
          settings."toolkit.legacyUserProfileCustomizations.stylesheets" = lib.mkDefault true;
          userChrome = lib.mkAfter ''
            /* Caelestia layout; independent of live colour theming.
               https://github.com/caelestia-dots/caelestia/blob/main/firefox/userChrome.css */
            .titlebar-buttonbox-container {
                display: none !important;
            }
            #urlbar:not([focused]) .urlbar-input {
                text-align: center !important;
            }
            #urlbar-background,
            #searchbar {
                border-radius: 10px !important;
            }
            .urlbar-page-action,
            #urlbar-go-button,
            .search-go-button,
            #tracking-protection-icon-container,
            #identity-icon-box,
            #identity-permission-box,
            .notification-anchor-icon,
            #userContext-icons,
            #urlbar-zoom-button,
            #page-action-buttons,
            .search-one-offs,
            #urlbar-search-mode-indicator {
                border-radius: 10px !important;
            }
            #urlbar[breakout][breakout-extend] {
                margin-top: 5px !important;
                margin-left: 0 !important;
                width: var(--urlbar-width) !important;
            }
          '';
        };
      });
    };
  };
}
