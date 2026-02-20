{
  self',
  ...
}: {
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
  };

  flake.aspects.wiki = {
    nixos = {
      environment.systemPackages = [self'.packages.wiki];
    };
    homeManager = {
      home.packages = [self'.packages.wiki];
    };
  };
}
