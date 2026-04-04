{
  flake.aspects = {aspects, ...} : {
    wsl = {
      includes = with aspects; [wsl-git-wrapper];

      nixos = {inputs, config, ...}: {
        imports = [inputs.nixos-wsl.nixosModules.wsl];

        wsl.enable = true;
        wsl.defaultUser = config.local.identity.username;
      };
      homeManager = {};
    };
  };
}
