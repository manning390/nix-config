{config,...}: {
  flake.aspects = {aspects, ...} : {
    wsl = {
      includes = with aspects; [wsl-git-wrapper];

      nixos = {inputs, ...}: {
        imports = [inputs.nixos-wsl.nixosModules.wsl];

        wsl.enable = true;
        wsl.defaultUser = config.local.identity.username;
      };
      homeManager = {};
    };
  };
}
