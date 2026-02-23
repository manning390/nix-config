{
  flake.aspects.docker = {
    nixos = {config,...}: {
      virtualization.docker.enable = true;
      users.users.${config.local.identity.username}.extraGroups = [ "docker" ];
    };
  };
}
