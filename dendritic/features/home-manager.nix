top @ {...}: {
  flake.aspects = {aspects, ...}:{
    homeManager._.users  = username: {
      includes = [aspects.${username}];

      nixos = {lib, inputs, config,...}: {
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
            imports = [top.config.flake.modules.homeManager.${username}];
            home = {
              homeDirectory = "/home/${username}";
              inherit username;
            };
            programs.home-manager.enable = true;
            # fonts.fontconfig.enble = true;
          };
        };
      };
    };
  };
}
