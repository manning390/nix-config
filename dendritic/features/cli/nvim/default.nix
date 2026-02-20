{self', config, lib, ...}: {
    flake.aspects.nvim = {
        homeManager = {pkgs,...}: {
            home.packages = [
                # self'.
            ];
        };
    };

    perSystem = {

    };
}
