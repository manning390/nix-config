{lib, ...}: {
  imports =
    [./hardware-configuration.nix]
    ++ builtins.map lib.custom.relativeToRoot [
      "modules/system.nix"
      "modules/sops.nix"
      "modules/zsh.nix"
    ];
  custom = {
    sops.enable = true;
  };

  system.stateVersion = "25.05";
}
