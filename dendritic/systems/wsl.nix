{config,...}: {
  flake.aspects.wsl = {
    nixos = {inputs, ...}: {
      imports = [inputs.nixos-wsl.nixosModules.wsl];

      wsl.enable = true;
      wsl.defaultUser = config.local.identity.username;
    };
  };
}
