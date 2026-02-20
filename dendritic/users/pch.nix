let
    username = "pch";
in
{
    flake.aspects = {aspects,...}: {
        ${username} = {
            includes = with aspects; [
                kitty
                wiki
                zoxide
            ];

            nixos = {
                users.users.${username} = {
                    isNormalUser = true;
                    extraGroups = ["wheel"];
                };
            };

            homeManager = {
                imports = [
                    ../../home/core/fish
                    ../../home/core/nvim
                ];

                programs = {
                    man.enable = true;
                    bat = {
                        enable = true;
                        # configs wip
                    };
                    fd.enable = true; # says doesn't exist?
                    btop.enable = true;
                    jq.enable = true;
                    aria2.enable = true;
                };
            };
        };
    };
}
