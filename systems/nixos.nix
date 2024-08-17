args:
with args;
with mylib;
with allSystemAttrs; let
  base_args = {
    inherit lib;
    inherit nixpkgs; # or nixpkgs-unsable
    inherit home-manager; #nixos-generators;
    system = x64_system;
    specialArgs = allSystemSpecialArgs.x64_system;
  };
in {
  nixosConfigurations = {
    sentry = nixosSystem (sentry_modules_hyprland // base_args);
  };

  # make system images
  # https://github.com/nix-community/nixos-generators
  # packages."${x64_system}" = attrs.mergeAttrsList [
  #   (
  #     attrs.listToAttrs
  #     [
  #       "sentry"
  #     ]
  #     # (host: self.nixosConfigurations.${host}.config.formats.iso)
  #   )
  # ];
}
