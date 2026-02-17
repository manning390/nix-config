{
  lib,
  ...
}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "home/core"
    "home/wsl/git-wrapper.nix"
  ];
  home.stateVersion = "25.05";
}
