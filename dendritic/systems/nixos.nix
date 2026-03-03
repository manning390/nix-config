{inputs,...}: {
    flake.aspects.nixos = {
        nixos = {
            imports = [inputs.determinate.nixosModules.default];
        };
        homeManager = {};
    };
}
