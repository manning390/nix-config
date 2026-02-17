{
  inputs,
  outputs,
}: let
  username = (import ../vars).username;
  mkSpecialArgs = nixpkgsVersion: machineHostname: {
    inherit inputs outputs;
    lib = nixpkgsVersion.lib.extend (self: super: {custom = import ../lib {inherit (nixpkgsVersion) lib;};});
    vars = (import ../vars) // {hostname = machineHostname;};
    self' = outputs; # This is an alias workaround so my non-flake-parts modules stay consistent with my flake-parts modules under the dendritic system, makes migration more seamless.
  };
  homeManagerCfg = userPackages: extraImports: hmExtraSpecialArgs: {
    home-manager.useGlobalPkgs = false;
    home-manager.extraSpecialArgs = {inherit inputs;} // hmExtraSpecialArgs;
    home-manager.users.${username}.imports =
      [
      ]
      ++ extraImports;
    home-manager.backupFileExtension = "hm.bak";
    home-manager.useUserPackages = userPackages;
  };
in {
  # mac devices
  mkDarwin = machineHostname: nixpkgsVersion: extraModules: hmExtraModules: {
    darwinConfigurations.${machineHostname} = inputs.nix-darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      specialArgs = mkSpecialArgs nixpkgsVersion machineHostname;
      modules = [
        ../hosts/darwin
        ../hosts/darwin/${machineHostname}
        inputs.home-manager-darwin.darwinModules.home-manager
        (nixpkgsVersion.lib.attrsets.recursiveUpdate (homeManagerCfg true hmExtraModules {
            inherit inputs outputs;
            vars = specialArgs.vars;
          }) {
            home-manager.users.${username}.home.homeDirectory = inputs.nixpkgs-darwin.lib.mkForce "/Users/${username}";
          })
      ];
    };
  };
  # Nixos
  mkNixos = machineHostname: nixpkgsVersion: extraModules: {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem rec {
      specialArgs = mkSpecialArgs nixpkgsVersion machineHostname;
      modules =
        [
          ../hosts/nixos/${machineHostname}
          (homeManagerCfg false [
              ../hosts/nixos/${machineHostname}/home.nix
            ] {
              inherit inputs outputs;
              vars = specialArgs.vars;
            })
        ]
        ++ extraModules;
    };
  };
  # Windows subsystem
  mkWsl = machineHostname: nixpkgsVersion: extraModules: hmExtraModules: {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = mkSpecialArgs nixpkgsVersion machineHostname;
      modules =
        [
          inputs.nixos-wsl.nixosModules.default
          ../hosts/wsl/${machineHostname}
          (homeManagerCfg false ([
              ../hosts/wsl/${machineHostname}/home.nix
            ]
            ++ hmExtraModules) {
            inherit inputs outputs;
            vars = specialArgs.vars;
          })
        ]
        ++ extraModules;
    };
  };
  mkMerge = inputs.nixpkgs.lib.foldl inputs.nixpkgs.lib.recursiveUpdate {};
}
