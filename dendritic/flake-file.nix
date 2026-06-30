{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.flake-file.flakeModules.dendritic # Configuration for dendritic setups with flake-file
    inputs.flake-file.flakeModules.nix-auto-follow # Optimizes the store by finding follows, sorta works?
  ];

  options.nixpkgsVersion = lib.mkOption {
    type = lib.types.singleLineStr;
    default = "unstable";
    example = "26.05";
    description = "The stable release label of nixpkgs to specify for all systems";
  };

  config = {
    nixpkgsVersion = "26.05";

    flake-file = {
      description = "Nix Configurations of Manning390";

      # Most inputs are defined near their configurations
      # Here is where some that don't have specific locations live
      inputs = {
        # Private nix module
        nix-private.url = "git+ssh://git@github.com/manning390/nix-private";

        # Disk Management
        disko.url = lib.mkDefault "github:nix-community/disko";

        # Ephemeral Root
        impermanence.url = lib.mkDefault "github:nix-community/impermanence";
      };

      # Must be in a string. This is an overwrite to use ./dendritic directory over modules
      outputs =
        # nix
        "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./dendritic)";
    };
  };
}
