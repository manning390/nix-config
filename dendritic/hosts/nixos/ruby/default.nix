{inputs, ...}: let
  hostname = "ruby";
  user = "ruby";
in {
  local.hosts.${hostname} = {
    type = "nixos";
    stateVersion = "24.05";
  };
  flake.aspects = {aspects, ...}: {
    ${hostname} = {
      description = "Host entrypoint for ruby";
      includes = with aspects; [
        base
        (homeManager._.users user)
        desktop
        caelestia
        discord
      ];

      nixos = {
        local.identity.username = user;
        imports = [
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ./_hardware-configuration.nix
          ../../../../modules/shells.nix
        ];

        local = {
          shells = {
            systemShell = "zsh";
            userShell = "zsh";
          };
          sops.enable = true;
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
