{config,...}: let
    hostname = "sage";
    user = config.local.identity.username;
in {
    local.hosts.${hostname} = {
        type = "wsl";
        stateVersion = "25.11";
    };
    flake.aspects = {aspects,...}: {
        ${hostname} = {
            includes = with aspects; [
                base 
                (homeManager._.users user)
                docker
            ];

            nixos = {config,...}: {
                imports = [
                    ../../../../modules/common.nix
                    ../../../../modules/shells.nix
                ];

                local = {
                    shells = {
                        systemShell = "fish";
                        userShell = "fish";
                    };
                    git.includeFile = config.sops.templates."gitconfig".path;
                };

                environment.sessionVariables = {
                    COLEMAK = "1";
                    NIXCONFIG = "/home/${user}/Code/nix/nix-config";
                };

                environment.shellAliases = {
                    whostname = "echo 'AP1H85254WLR' | clip.exe";
                };

                sops.secrets."npm/npmrc" = {
                    sopsFile = ./secrets/sage.yaml;
                    path = "/home/${user}/.npmrc";
                    owner = user;
                    group = "users";
                    mode = "0600";
                };
                sops.secrets."workemail" = {
                    sopsFile = ./secrets/sage.yaml;
                    owner = user;
                    group = "users";
                    mode = "0600";
                };
                sops.templates."gitconfig"= {
                    content = ''
                        [user]
                            email = ${config.sops.placeholder.workemail}
                    '';
                    owner = user;
                    group = "users";
                    mode = "0600";
                };
            };

            homeManager = {
                imports = [
                    ./_daily_logging.nix
                ];
            };
        };
    };
}
