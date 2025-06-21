{
  lib,
  pkgs,
  ...
}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "home/core"
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 5d --keep 3";
      };
    };
  };
  home.packages = with pkgs; [
    nh
    nix-output-monitor
    nvd
  ];

  home.stateVersion = "25.05";
}
