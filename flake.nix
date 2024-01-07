{
  description = "NixOs Configuration of Manning390";

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  } @ inputs: let
    constants = import ./constants.nix;

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forEachSystem = func: (nixpkgs.lib.genAttrs constants.allSystems func);

    allSystemConfigurations = import ./systems {inherit self inputs constants;};
  in {
    allSystemConfigurations {
      # format the nix code in this flake
      # alejandra is a nix formatter with a beautiful output
      formatter = forEachSystem {
        system: nixpkgs.legacyPackages.${system}.alejandra
      };

      # pre-commit hooks for nix code
      checks = forEachSystem (
        system: {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true; # formatter
              statix.enable = true; # lints and suggestions for nix code(auto suggestions)
              prettier = {
                enable = true;
                excludes = [".js" ".md" ".ts"];
              };
            };
          };
        }
      );

      devShells = forEachSystem (
        system: {
          default = nixpkgs.legacyPackages.${system}.mkShell {
            packages = [
              # fix https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
              nixpkgs.legacyPackages.${system}.bashInteractive
            ];
            name = "dots";
            shellHook = ''
              ${self.checks.${system}.pre-commit-check.shellHook}
            '';
          };
        }
      );
    };
  };

  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  #     https://nixos-and-flakes.thiscute.world/nixos-with-flakes/add-custom-cache-servers
  nixConfig = {
    extra-substituters = [
      "https://anyrun.cachix.org"
      # "https://hyprland.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's stable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # for macos
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home-manager, used for managing user configuration
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # hyprland = {
    #   url = "github:hyprwm/Hyprland/v0.33.1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    # anyrun - a wayland launcher
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # add git hooks to format nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Color themes
    # nix-colors.url = "github:misterio77/nix-colors";
  };
}
