{
  description = "Nix Configurations of Manning390";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # Disk Management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Ephemeral Root
    impermanence.url = "github:nix-community/impermanence";

    # Windows WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # MacOS Nix
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Secrets Managment
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Hardward specific configs
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Zsh plugin manager
    zinit.url = "github:zdharma-continuum/zinit";
    zinit.flake = false;

    # Automagic/breaking Color Themes
    stylix.url = "github:danth/stylix/release-25.11";

    # Currated Taskbar
    # hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    # hyprpanel.inputs.nixpkgs.follows = "nixpkgs";

    # Utility scripts, like screen shots
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nightly
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (self) outputs;
    flakehelpers = import ./lib/flakeHelpers.nix {inherit inputs outputs;};
    inherit (flakehelpers) mkMerge mkNixos mkWsl;
  in
    mkMerge [
      { overlays = import ./overlays { inherit inputs; }; }
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
        }
      ))
      # Desktop
      (mkNixos "sentry" inputs.nixpkgs [
        inputs.nur.modules.nixos.default
        inputs.home-manager.nixosModules.home-manager
      ])
      # Framework laptop
      (mkNixos "ruby" inputs.nixpkgs [
        inputs.nur.modules.nixos.default
      ])
      # Homelab
      (mkNixos "glaciem" inputs.nixpkgs [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
      ])
      # Windows WSL environment
      (mkWsl "mado" inputs.nixpkgs [
        inputs.nur.modules.nixos.default
        inputs.home-manager.nixosModules.home-manager
      ] [])
    ];
}
