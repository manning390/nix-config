{config,...}: let
    hostname = "mado";
    user = config.local.identity.username;
in {
    local.hosts.${hostname} = {
        type = "wsl";
        stateVersion = "24.11";
    };
    flake.aspects = {aspects, ...}: {
        ${hostname} = {
            includes = with aspects; [
                base
                (homeManager._.users user)
            ];

            nixos = {
                imports = [
                    ../../../modules/common.nix
                    ../../../modules/shells.nix
                ];

                local = {
                    shells = {
                        systemShell = "fish";
                        userShell = "fish";
                    };
                };

                environment.sessionVariables = {
                    COLEMAK = "1";
                    # NIXCONFIG = "/home/${user}/Code/nix/nix-config";
                };
            };

            homeManager = {}; # Required for included homeMager modules to be imported
        };
    };
}
