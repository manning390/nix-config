{self,...}: let
  hostname = "sentry";
  user = "pch";
in {
  # Not activating yet...
  # local.hosts.${hostname} = {
  #   type = "nixos";
  #   stateVersion = "23.11";
  # };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "Slim Gray Desktop";

      includes = with aspects; [
        base
        (hardware hostname)
        (homeManager._.users user)
      ];

      nixos = {
        imports = [ self.nixosModules."${hostname}_hardware" ];
        local = {
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
        };

        environment.sessionVariables = {
          COLEMAK = "1";
          NIXCONFIG = "/home/${user}/Code/nix/nix-config";
        };
      };

      homeManager = {}; # Required for included homeMager modules to be imported
    };
  };
}
