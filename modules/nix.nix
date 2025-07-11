{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}: {
  options.custom.nix = {
    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow unfree packages to be built on this system.
      '';
    };
    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/home/${vars.username}/Code/nix/nix-config";
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
      flag = lib.mkOption {
          type = lib.types.str;
          default = "--delete-older-than 7d --keep 3";
          description = ''
            Setting of gc.options and nh.clean.extraArgs for how many versions to keep.
          '';
        };
    };
  };

  config = {
    nix = {
      settings = {
        # enable flakes globally
        experimental-features = ["nix-command" "flakes"];
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        trusted-users = ["root" vars.username];
      };

      # Garbage Collection
      gc = {
        dates = lib.mkDefault "daily";
        options = config.custom.nix.gc.flag;
      };
      gc.automatic = !config.custom.nix.gc.useNh;

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
      flake = config.custom.nix.flakePath;
      clean.enable = config.custom.nix.gc.useNh;
      clean.extraArgs = config.custom.nix.gc.flag;
    };
    environment.systemPackages = with pkgs; [
      nh
      nix-output-monitor
      nvd
    ];

    # Allow unfree packages
    nixpkgs.config = lib.mkIf config.custom.nix.allowUnfree {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
