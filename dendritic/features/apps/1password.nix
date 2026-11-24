{
  # underscore because starting with digit is invalid nix
  flake.aspects._1password = {
    description = "Password Vault CLI and Desktop clients";

    nixos = {
      config,
      lib,
      ...
    }: let
      user = config.local.identity.username;
    in {
      # These are unfree, by default I allow unfree
      # Setting is in base/nix aspect
      programs = {
        _1password.enable = true;
        _1password-gui = {
          enable = true;
          polkitPolicyOwners = [user];
        };
        firefox.policies.ExtensionSettings = lib.mkIf config.programs.firefox.enable {
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          };
        };
      };
    };

    homeManager = {lib, ...}: {
      wayland.windowManager.hyprland.settings.windowrule = lib.mkAfter [
        "float on, match:class ^(1password)$"
      ];
    };
  };
}
