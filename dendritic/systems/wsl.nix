{
  flake.aspects.wsl = {
    nixos = {config, inputs, ...}: {
      imports = [inputs.nixos-wsl.nixosModules.wsl];

      wsl.enable = true;
      wsl.defaultUser = config.local.identity.username;
    };
  };
}
