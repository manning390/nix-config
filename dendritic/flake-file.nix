{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.flake-file.flakeModules.dendritic # Configuration for dendritic setups with flake-file
    inputs.flake-file.flakeModules.nix-auto-follow # Optimizes the store by finding follows, sorta works?
  ];

  flake-file = {
    description = "Nix Configurations of Manning390";
    inputs = let
      version = "26.05";
    in {
      # Nixpkgs
      nixpkgs.url = "github:nixos/nixpkgs/nixos-${version}";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

      # Home Manager
      home-manager.url = "github:nix-community/home-manager/release-${version}";

      # Private nix module
      nix-private.url = "git+ssh://git@github.com/manning390/nix-private";

      # Flake aspects
      flake-aspects.url = lib.mkDefault "github:denful/flake-aspects";

      # Disk Management
      disko.url = lib.mkDefault "github:nix-community/disko";

      # Ephemeral Root
      impermanence.url = lib.mkDefault "github:nix-community/impermanence";

      # Nvim nix plugin patching
      # nixPatch.url = "git+https://codeberg.org/NicoElbers/nixPatch-nvim.git";
      # nixPatch.inputs.neovim-nightly-overlay.follows = "neovim-nightly-overlay";
      # nixPatch.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs =
      # nix
      "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./dendritic)"; # Must be in a string. This is an overwrite to use ./dendritic directory over modules
  };
}
