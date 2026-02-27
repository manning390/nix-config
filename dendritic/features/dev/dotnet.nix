{self, ...}: let
  name = "dotnet";
in {
  perSystem = {config, pkgs, ...}: {
    devShells = {
      ${name} = pkgs.mkShell {
        inherit name;
        packages = [
          # dotnet-sdk
          pkgs.dotnet-sdk_10
          pkgs.dotnet-ef
          self.packages.${pkgs.stdenv.hostPlatform.system}.easy-dotnet-server
        ];
        shellHook = ''
          echo "Oh, .Net eh? Nice nice..."
          dotnet --version
        '';
      };
    };
  };
}
