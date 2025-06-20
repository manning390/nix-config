{
  description = "Nix Configurations of Manning390";
  nixConfig = {};
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Windows WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # MacOS Nix
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Zsh plugin manager
    zinit.url = "github:zdharma-continuum/zinit";
    zinit.flake = false;

    # Color themes
    stylix.url = "github:danth/stylix/release-25.05";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";

    # Utility scripts, like screen shots
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nightly
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Firefox nightly
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    # Sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Hardward specific configs
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    flakehelpers = import ./lib/flakeHelpers.nix inputs;
    inherit (flakehelpers) mkMerge mkNixos mkWsl;
  in
    mkMerge [
      (flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          packages.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.nixos-rebuild
            ];
          };
          formatter = pkgs.alejandra;
          # overlays.default = import ./overlays { inherit inputs; };
        }
      ))
      (mkNixos "sentry" inputs.nixpkgs [
        inputs.stylix.nixosModules.stylix
        inputs.nur.modules.nixos.default
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkNixos "ruby" inputs.nixpkgs [
        inputs.stylix.nixosModules.stylix
        inputs.nur.modules.nixos.default
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
      ])
      (mkWsl "mado" inputs.nixpkgs [
        inputs.home-manager.nixosModules.home-manager
      ] [])
    ];
}
