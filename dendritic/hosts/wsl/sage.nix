{config, ...}: let
    machineName = "sage";
    user = config.local.identity.username;
in {
    local.hosts.${machineName} = {
        type = "wsl";
        stateVersion = "25.11";
    };
    flake.aspects = {aspects,...}: {
        ${machineName} = {
        includes = with aspects; [
            base 
            homeManager._.users "${user}"
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
                NIXCONFIG = "/home/${user}/Code/nix/nix-config";
            };

            environment.shellAliases = {
                whostname = "echo 'AP1H85254WLR' | clip.exe";
            };

            sops.secrets."npm/npmrc" = {
                sopsFile = ../../../secrets/sage.yaml;
                path = "/home/${user}/.npmrc";
                owner = user;
                group = "users";
                mode = "0600";
            };
        };

        homeManager = {
            imports = [
                ../../../home/wsl/git-wrapper.nix
            ];
        };
    };
    };
}
