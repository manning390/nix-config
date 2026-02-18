{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-aspects.flakeModule];

  options.local.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.submodule (
      {config, name, ...}: {
        options = {
          type = lib.mkOption {
            type = lib.types.enum ["nixos" "wsl"];
            description = "Type of host configuration";
          };
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
          };
          modules = lib.mkOption {
            type = lib.types.listOf (lib.types.oneOf [
              lib.types.path
              lib.types.deferredModule
            ]);
            default = [];
            description = "The NixOS modules for this host";
          };
          aspects = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Aspect names to include for this host";
          };
          homeManagerModules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
          };
          stateVersion = lib.mkOption {
            type = lib.types.str;
            default = "25.11";
            description = "NixOS state version";
          };
        };
      }
    ));
    default = {};
    description = "Host configurations.";
  };

  config.flake = let
    username = config.local.identity.username;
    extendedLib = inputs.nixpkgs.lib.extend (self: super: {
      custom = import ../../lib {inherit (inputs.nixpkgs) lib;};
    });
    mkHomeManager = hostName: aspects: homeManagerModules: stateVersion: {
      home-manager = {
        useGlobalPkgs = false;
        extraSpecialArgs = {
          inherit inputs;
          vars = import ../../vars;
        };
        users.${username} = {
          home.stateVersion = stateVersion;
          home.homeDirectory = lib.mkDefault "/home/${username}";
          programs.home-manager.enable = true;
          systemd.user.startServices = "sd-switch";
          imports =
            homeManagerModules
            ++ (map (aspect: config.flake.modules.homeManager.${aspect})
              (lib.filter (a: config.flake.modules.homeManager ? ${a}) aspects));
        };
        backupFileExtension = "hm.bak";
        useUserPackages = false;
      };
    };
    mkNixosConfig = machineName: hostCfg:
      inputs.nixpkgs.lib.nixosSystem {
        system = hostCfg.system;
        # Todo effectively remove special args later
        specialArgs = {
          inherit inputs;
          vars = import ../../vars;
          lib = extendedLib;
        };
        modules = let
          baseModules = lib.optional (hostCfg.type == "wsl") inputs.nixos-wsl.nixosModules.default;
          foundationModules = lib.mapAttrsToList (_: mod: mod.nixos) config.flake.modules.foundation;
          aspectModules =
            map (aspect: config.flake.modules.nixos.${aspect})
            (lib.filter (a: config.flake.modules.nixos ? ${a}) hostCfg.aspects);
          hmModule = mkHomeManager machineName hostCfg.aspects hostCfg.homeManagerModules hostCfg.stateVersion;
          stateVersionModule = {system.stateVersion = hostCfg.stateVersion;};
        in
          baseModules
          ++ foundationModules
          ++ aspectModules
          ++ hostCfg.modules
          ++ [hmModule stateVersionModule inputs.home-manager.nixosModules.home-manager];
      };
  in {
    nixosConfigurations = lib.mapAttrs mkNixosConfig config.local.hosts;
    checks.x86_64-linux =
      lib.mapAttrs (machineName: _: {
        "configuration:${machineName}" = config.flake.nixosConfigurations.${machineName}.config.system.build.toplevel;
      })
      config.local.hosts;
  };
}
