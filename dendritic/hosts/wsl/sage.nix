{config, inputs, lib, ...}: let
    machineName = "sage";
    user = config.local.identity.username;
in {
    config.local.hosts.${machineName} = {
        type = "wsl";
        aspects = [];
        modules = [
            inputs.determinate.nixosModules.default
            ../../../modules/wsl
            ../../../modules/nix.nix
            ../../../modules/common.nix
            ../../../modules/sops.nix
            ../../../modules/shells.nix
            {
                networking.hostName = machineName;

                users.users.${user} = {
                    isNormalUser = true;
                };

                custom = {
                    wsl.enable = true;
                    shells = {
                        systemShell = "fish";
                        userShell = "fish";
                    };
                    sops.enable = true;
                    nix.allowUnfree = true;
                };

                environment.sessionVariables = {
                    COLEMAK = "1";
                    NIXCONFIG = "/home/${user}/Code/nix/nix-config";
                };

                environment.shellAliases = {
                    whostname = "echo 'AP1H85254WLR' | clip.exe";
                };

                sops.secrets."npm/npmrc" = {
                    sopsFile = lib.custom.relativeToRoot "secrets/sage.yaml";
                    path = "/home/${user}/.npmrc";
                    owner = user;
                    group = "users";
                    mode = "0600";
                };
            }
        ];
        homeManagerModules = [
            ../../../home/core
            ../../../home/wsl/git-wrapper.nix
        ];
        stateVersion = "25.11";
    };
}
