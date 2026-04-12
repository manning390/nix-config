{self, inputs, ...}: let
  name = "dotnet";
in {
  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    devShells = {
      ${name} = pkgs.mkShell {
        inherit name;
        packages = [
          # dotnet-sdk
          (with pkgs.dotnetCorePackages; combinePackages [
            sdk_8_0
            sdk_10_0
          ])
          pkgs.dotnet-ef
          self.packages.${pkgs.stdenv.hostPlatform.system}.easy-dotnet-server
          (pkgs.azure-cli.withExtensions [
            pkgs.azure-cli.extensions.fzf
            pkgs.azure-cli.extensions.application-insights
            pkgs.azure-cli.extensions.front-door
          ])
          pkgs.azure-functions-core-tools
        ];
        shellHook = ''
          echo "Oh, .Net eh? Nice nice..."
          dotnet --version
        '';
      };
    };
  };
}
