{
  description = "NixOs Configurations of Manning390";

  # The nixConfig here only affects the flake, not system config.
  nixConfig = {};

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # Cursor theme
    nordzy-hyprcursors.url = "github:guillaumeboehm/Nordzy-cursors";
    nordzy-hyprcursors.flake = false;

    # Zsh plugin manager
    zinit.url = "github:zdharma-continuum/zinit";
    zinit.flake = false;

    # Color themes
    stylix.url = "github:danth/stylix/release-24.11";

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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (inputs.nixpkgs) lib;
    mylib = import ./lib {inherit lib;};
    myvars = import ./vars {inherit lib;};

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    # nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    # homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      sentry = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs myvars mylib;};
        modules = [
          ./hosts/sentry
          inputs.stylix.nixosModules.stylix
          inputs.nur.modules.nixos.default
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs myvars mylib;};
            home-manager.users.${myvars.username} = import ./home/linux/desktop.nix;
          }
        ];
      };

      ruby = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs myvars mylib;} // {
          myvars = {
            username = "ruby";
          };
        };
        modules = [
          ./hosts/ruby
          inputs.stylix.nixosModules.stylix
          inputs.nur.modules.nixos.default
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs myvars mylib;};
            home-manager.users.${myvars.username} = import ./home/linux/desktop.nix;
          }
        ];
      };
    };
  };
}
