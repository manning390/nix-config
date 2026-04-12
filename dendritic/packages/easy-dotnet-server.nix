{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.easy-dotnet-server = pkgs.buildDotnetGlobalTool {
      pname = "dotnet-easydotnet";
      nugetName = "EasyDotnet";
      version = "3.0.27";
      nugetHash = "sha256-pgoATXRFus2ppfAgc8LpqlNd9sb+9rHqGfifQFL+RMw=";

      meta = {
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

