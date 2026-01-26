# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  lib,
  vars,
  pkgs,
  ...
}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "modules/nix.nix"
    "modules/common.nix"
    "modules/sops.nix"
    # WSL included from flake helper
  ];

  wsl.enable = true;
  wsl.defaultUser = vars.username;
  networking.hostName = vars.hostname;

  # Shell
  environment.shells = [pkgs.zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  users.users."${vars.username}" = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  environment.sessionVariables = {
    COLEMAK = "1";
  };

  custom = {
    sops.enable = true;
    nix.allowUnfree = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
