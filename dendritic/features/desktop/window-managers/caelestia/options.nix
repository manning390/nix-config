{
  flake.modules = {
    nixos.caelestia-options = {lib, ...}: {
      options.local.desktop.caelestia = {
        allowSuspend = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Allow system sleep. Disable on machines with unreliable resume.";
        };
        vpn = {
          providers = lib.mkOption {
            default = [];
            description = "VPN providers registered with the shell. Define connection-specific values in private configuration.";
            type = lib.types.listOf (lib.types.submodule {
              options = {
                id = lib.mkOption {
                  type = lib.types.nonEmptyStr;
                  description = "Stable, unique provider identifier.";
                };
                name = lib.mkOption {
                  type = lib.types.nonEmptyStr;
                  description = "Caelestia provider adapter name.";
                };
                displayName = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Provider label shown by the shell.";
                };
                interface = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Interface used by the provider's status check.";
                };
                connectCmd = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = "Connection command and arguments; empty uses the adapter default. Never include secrets.";
                };
                disconnectCmd = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = "Disconnection command and arguments; empty uses the adapter default. Never include secrets.";
                };
              };
            });
          };
          selectedProvider = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
            description = "Initial provider identifier, or null to let the shell choose.";
          };
        };
      };
    };

    homeManager.caelestia-options = {lib, ...}: {
      options.local.desktop.caelestia = {
        enable = lib.mkEnableOption "enables caelstia shell";
        wallpaperDir = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "~/Pictures/Wallpapers";
          description = "where your wallpapers will be sourced";
        };
        showBattery = lib.mkEnableOption "shows battery in left sidebar";
        showBrightness = lib.mkEnableOption "shows brightness slider in right sidebar";
        writableSettings = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Use a writable shell.json so the settings UI can save changes.
            UI changes persist until the generated Nix settings change; then
            the previous file is backed up as shell.json.before-nix and the
            new Nix settings are applied.
          '';
        };
        idle = {
          lockAfter = lib.mkOption {
            type = lib.types.ints.positive;
            default = 180;
            description = "Idle seconds before locking the session.";
          };
          screensOffAfter = lib.mkOption {
            type = lib.types.ints.positive;
            default = 300;
            description = "Idle seconds before turning displays off (DPMS, not system sleep).";
          };
          suspendAfter = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = null;
            description = "Idle seconds before suspending, or null to disable automatic suspend.";
          };
          suspendOnAC = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Also automatically suspend while connected to external power.";
          };
        };
        excludedScreens = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          default = [];
          example = ["HDMI-A-1" "HDMI-A-2"];
          description = "Screens to not show the taskbar";
        };
      };
    };
  };
}
