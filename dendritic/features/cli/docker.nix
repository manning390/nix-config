{
  flake.aspects.docker = {
    nixos = {config,...}: {
      virtualisation.docker.enable = true;
      users.users.${config.local.identity.username}.extraGroups = [ "docker" ];
    };
  };
}
