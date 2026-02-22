top: {
  flake.aspects = {aspects, ...}:{
    homeManager._.users  = username: {
      description = "Parameterized aspect, takes username and imports and sets up home-manager.";

      includes = [aspects.${username}];

      nixos = { config, inputs, ...}: {
        imports = [inputs.home-manager.nixosModules.home-manager];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
            vars = import ../../vars; # Temp until everything dendritic
          };
          backupFileExtension = "hmbak";

          users.${username} = {
            # import host's homeManager aspect which includes the user
            imports = [
              top.config.flake.modules.homeManager.${config.networking.hostName}
            ];
            home = {
              homeDirectory = "/home/${username}";
              inherit username;
              stateVersion = config.system.stateVersion;
            };
            programs.home-manager.enable = true;
            # fonts.fontconfig.enble = true;
          };
        };
      };
    };
  };
}
