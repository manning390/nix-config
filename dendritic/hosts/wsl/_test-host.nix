{config, inputs,...}: let
    self = config.flake.modules;
    machineName = "test";
    user = config.local.identity.username;
    stateVersion = "25.11";
in {
    config.local.hosts.${machineName} = {
        type = "wsl";
        stateVersion = "25.11";
    };
    config.flake.aspects.hosts.${machineName} = {aspects,...}: {
        nixos = {
            users.users.${user} = {
                isNormalUser = true;
            };
        };
        includes = with aspects; [
            git
        ];
    };
}
