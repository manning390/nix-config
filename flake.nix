# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Nix Configurations of Manning390";

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./dendritic);

  inputs = {
    caelestia-shell.url = "github:caelestia-dots/shell";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    disko.url = "github:nix-community/disko";
    flake-aspects.url = "github:denful/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    hyprland-contrib.url = "github:hyprwm/contrib";
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-private.url = "git+ssh://git@github.com/manning390/nix-private";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    zinit = {
      url = "github:zdharma-continuum/zinit";
      flake = false;
    };
  };
}
