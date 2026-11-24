{
  local.hosts.phone = {
    type = "android";
    system = "aarch64-linux";
    # Nix-on-Droid's state version is independent of the Nixpkgs release.
    stateVersion = "24.05";
  };

  flake.aspects.phone = {
    description = "Android phone SSH and editing environment";

    # Add phone-specific Nix-on-Droid options here. The dispatcher also imports
    # the android system aspect; deliberately don't include the NixOS base.
    android = {};
  };
}
