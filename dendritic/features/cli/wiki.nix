{self, ...}: {
  # imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
  perSystem = {pkgs, lib, ...}: {
    packages.wiki = pkgs.buildGoModule rec {
      pname = "wiki";
      version = "1.4.1";

      src = pkgs.fetchFromGitHub {
        owner = "walle";
        repo = "wiki";
        rev = "v${version}";
        sha256 = "sha256-LFiS5X+3qZmt2IIoXFuNtHQ8J7fVgfVXctYh/4obP9U=";
      };

      vendorHash = null;

      subPackages = ["cmd/wiki"];

      ldflags = [
        "-s"
        "-w"
        "-X main.version=${version}"
      ];

      postInstall = ''
        install -Dm644 _doc/wiki.1 $out/share/man/man1/wiki.1
      '';

      meta = with lib; {
        description = "Command line tool to get Wikipedia summaries";
        homepage = "https://github.com/walle/wiki";
        license = licenses.mit;
        maintainers = with maintainers; [
          /*
          Add yourself here
          */
        ];
      };
    };
    # overlayAttrs.wiki = config.packages.wiki;
  };

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
