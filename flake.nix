{
  description = "Nix Configurations of Manning390";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Determinate Systems
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Private nix module
    nix-private.url = "git+ssh://git@github.com/manning390/nix-private";
    nix-private.inputs.nixpkgs.follows = "nixpkgs";

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # Flake aspects
    flake-aspects.url = "github:vic/flake-aspects";

    # Import util
    import-tree.url = "github:vic/import-tree";

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

    # Utility scripts, like screen shots
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    # Caelestia wm theme
    caelestia-shell.url = "github:caelestia-dots/shell";
    caelestia-shell.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nightly
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      inputs.nixpkgs.lib.foldl inputs.nixpkgs.lib.recursiveUpdate {} [
        {
          systems = ["x86_64-linux"];
          perSystem = {pkgs, ...}: {
            devShells.default = pkgs.mkShell {
              packages = with pkgs; [just nixos-rebuild];
            };
            formatter = pkgs.alejandra;
          };

          flake = let
            flakehelpers = import ./lib/flakeHelpers.nix {
              inherit inputs;
              outputs = self.outputs or {};
            };
            inherit (flakehelpers) mkMerge mkNixos mkWsl;
          in
            mkMerge [
              {overlays = import ./overlays {inherit inputs;};}
              # Desktop
              (mkNixos "sentry" inputs.nixpkgs [
                inputs.nur.modules.nixos.default
                inputs.home-manager.nixosModules.home-manager
                inputs.determinate.nixosModules.default
              ])
              # Framework laptop
              (mkNixos "ruby" inputs.nixpkgs [
                inputs.nur.modules.nixos.default
              ])
              # Homelab
              # (mkNixos "glaciem" inputs.nixpkgs [
              #   inputs.disko.nixosModules.disko
              #   inputs.impermanence.nixosModules.impermanence
              #   inputs.home-manager.nixosModules.home-manager
              # ])
              # Windows WSL environment
              (mkWsl "mado" inputs.nixpkgs [
                inputs.nur.modules.nixos.default
                inputs.home-manager.nixosModules.home-manager
              ] [])
              # (mkWsl "sage" inputs.nixpkgs [
              #   inputs.home-manager.nixosModules.home-manager
              # ] [])
            ];
        }
        (inputs.import-tree ./dendritic)
      ]
    );
}
