# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  myvars,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ../core
    ./wm/hyprland
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 5d --keep 3";
        flake = "/home/${myvars.username}/nix-config";
      };
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    discord-canary

    nh
    nix-output-monitor
    nvd

    # Peripheral utilities
    headsetcontrol # minor support for G733 Logi headset
    ncpamixer # Audio levels cli
  ];
}
