{self, ...}: {
  # imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  flake.aspects.wiki = {
    nixos = {pkgs,...}: let
      system = pkgs.stdenv.hostPlatform.system;
    in {
      environment.systemPackages = [self.packages.${system}.wiki];
    };

    homeManager = {pkgs,...}: let
        system = pkgs.stdenv.hostPlatform.system;
    in {
      home.packages = [self.packages.${system}.wiki];
    };
  };
}
