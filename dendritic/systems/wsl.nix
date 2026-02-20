{
  flake.aspects.wsl = {
    nixos = {inputs, config, ...}: {
      imports = [inputs.nixos-wsl.nixosModules.wsl];

      wsl.enable = true;
      wsl.defaultUser = config.local.identity.username;
    };
  };
}
