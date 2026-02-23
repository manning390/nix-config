{
  config,
  inputs,
  lib,
  ...
}: let 
  hosts = config.local.hosts;
  # Maps from system type to flake configurations
  typeDispatch = rec {
    nixos = {
      flakeAttr = "nixosConfigurations";
      builder = inputs.nixpkgs.lib.nixosSystem;
      class = "nixos";
    };
    wsl = nixos; # The same except wsl gets the system.wsl aspect
    darwin = {
      flakeAttr = "darwinConfigurations";
      builder = inputs.nix-darwin.lib.darwinSystem;
      class = "darwin";
    };
  };
  # Creates a host based on type, includes host and system aspects
  mkHost = hostname: hostCfg:
    let cfg = typeDispatch.${hostCfg.type};
    in cfg.builder {
      inherit (hostCfg) system;
      specialArgs = {
        inherit inputs /* hostname hostCfg */;
        vars = import ../../vars; # Temp until everything dendritic
      };
      modules = [
        inputs.self.modules.${cfg.class}.${hostname}
        inputs.self.modules.${cfg.class}.${hostCfg.type}
        ../base/identity.nix # Hack for identity to be available in nixos config
        {
          networking.hostName = hostname;
          system.stateVersion = hostCfg.stateVersion;
        }
      ];
    };
  attrGroupBy = f: attrs: attrs
    |> lib.mapAttrsToList (name: value: { inherit name value; })
    |> lib.groupBy (x: f x.value)
    |> lib.mapAttrs (key: list: list
      |> builtins.map (x: { inherit (x) name; value = x.value; })
      |> lib.listToAttrs
    );
in {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-aspects.flakeModule
  ];

  # This option is the entrypoint for hosts
  options.local.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule (
      {name,...}: {
        options = {
          type = lib.mkOption {
            type = lib.types.enum ["nixos" "wsl" "darwin"];
            description = "Type of host configuration";
          };
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
            description = "System architecture target";
          };
          stateVersion = lib.mkOption {
            type = lib.types.str;
            default = "25.11";
            description = "NixOS state version";
          };
          extraModules = lib.mkOption {
            type = lib.types.listOf (lib.types.oneOf [
              lib.types.path
              lib.types.deferredModule
            ]);
            default = [];
            description = "Additional nixos class modules for this host";
          };
        };
      }
    ));

    default = {};
    description = "Host configurations";
  };

  # Iterates through host options, creates host and checks
  config.flake = hosts
    |> attrGroupBy (host: typeDispatch.${host.type}.flakeAttr)
    |> lib.mapAttrs (_: lib.mapAttrs mkHost);
    # |> (baseFlake: baseFlake // {
    #   checks = lib.mapAttrs (name: cfg: {
    #       "host-${name}" = cfg;
    #     }) baseFlake;
    # });
}

