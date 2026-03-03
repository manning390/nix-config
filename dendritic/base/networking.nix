{
  flake.aspects.networking = {
    description = "Networking settings and utilities";

    nixos = {config, pkgs,lib,...}: let
        cfg = config.local.hardware.networking;
    in {
      options.local.hardware.networking = {
        enable = lib.mkEnableOption "Install networking related packages";
      };
      config = lib.mkIf cfg.enable {
          networking = {
            # Hostname is set by hosts/default
            networkmanager.enable = true;
          };

          hardware.bluetooth.enable = lib.mkDefault true;

          environment.systemPackages = with pkgs; [
            wget
            curl
            nmap
          ];
        };
    };

    homeManager = {osConfig, lib, ...}: let
      cfg = osConfig.local.hardware.networking;
    in {
      config = lib.mkIf cfg.enable {
        programs.aria2.enable = true;
      };
    };
  };
}
