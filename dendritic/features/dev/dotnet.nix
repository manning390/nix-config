{self,...}: let
  name = "dotnet";
in {
  perSystem = {config, pkgs, ...}: {
    devShells = {
      ${name} = pkgs.mkShell {
        inherit name;
        packages = with pkgs; [
          # dotnet-sdk
          dotnet-sdk_10
          dotnet-ef
          self.packages.${pkgs.stdenv.hostPlatform.system}.easy-dotnet-server
        ];
        shellHook = ''
          echo "Oh, .Net eh? Nice nice..."
        '';
      };
    };
  };
}
