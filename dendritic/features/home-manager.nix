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
            # Import homeManager modules through host and system type aspects
            imports = let
              hmModules = top.config.flake.modules.homeManager; 
              hostname = config.networking.hostName;
            in [
              hmModules.${hostname}
              hmModules.${top.config.local.hosts.${hostname}.type}
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
