{config, ...}: {
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-${config.nixpkgsVersion}";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  flake.aspects.nix = {
    nixos = {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }: let
      user = config.local.identity.username;
    in {
      options.local.nix = {
        allowUnfree = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Allow unfree packages to be built on this system.
          '';
        };
        flakePath = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "/home/${user}/Code/nix/nix-config";
          description = ''
            Where the nixos config is stored on the system.
          '';
        };
        gc = {
          useNh = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Should use program.nh.clean to garbage collect instead of nix.gc.automatic.
            '';
          };
          keepSince = lib.mkOption {
            type = lib.types.singleLineStr;
            default = "7d";
            description = ''
              Keep generations from this duration ago until now. This uses the
              duration format accepted by both nix-collect-garbage and nh.
            '';
          };
          keepGenerations = lib.mkOption {
            type = lib.types.addCheck lib.types.int (value: value > 0);
            default = 3;
            description = ''
              Minimum number of generations retained by nh cleanup.
            '';
          };
        };
      };

      config = {
        nix = {
          settings = {
            # enable flakes globally
            experimental-features = ["nix-command" "flakes" "pipe-operators"];
            # Deduplicate and optimize nix store
            auto-optimise-store = true;
            trusted-users = ["${user}"];
          };

          # Garbage Collection
          gc = {
            dates = lib.mkDefault "daily";
            options = "--delete-older-than ${config.local.nix.gc.keepSince}";
          };
          gc.automatic = !config.local.nix.gc.useNh;

          # This will add each flake input as a registry
          # To make nix3 commands consistent with your flake
          registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
        };

        # This will additionally add your inputs to the system's legacy channels
        # Making legacy nix commands consistent as well, awesome!
        nix.nixPath = ["/etc/nix/path"];
        environment.etc =
          lib.mapAttrs'
          (name: value: {
            name = "nix/path/${name}";
            value.source = value.flake;
          })
          config.nix.registry;

        # Nix cli command helper, better output etc.
        programs.nh = {
          enable = true;
          flake = config.local.nix.flakePath;
          clean.enable = config.local.nix.gc.useNh;
          clean.extraArgs = "--keep-since ${config.local.nix.gc.keepSince} --keep ${toString config.local.nix.gc.keepGenerations}";
        };
        environment.systemPackages = with pkgs; [
          nh
          nix-output-monitor
          nvd
          alejandra
        ];

        nixpkgs = {
          # Allow unfree packages
          config = lib.mkIf config.local.nix.allowUnfree {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
          # use unstable packages with pkgs.unstable.<pkg name>
          overlays = [
            (final: prev: {
              unstable = import inputs.nixpkgs-unstable {
                system = final.stdenv.hostPlatform.system;
                config.allowUnfree = config.local.nix.allowUnfree;
              };
            })
          ];
        };
      };
    };
  };
}
