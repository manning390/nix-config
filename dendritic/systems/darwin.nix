{
    #systems = ["aarch64-darwin"];  # This is a flake-part setting and therefore imported everywhere, here for semantic reasons
    flake.aspects.darwin = {
        darwin = {};
        homeManager = {};
    };
}
