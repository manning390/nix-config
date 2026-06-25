{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.easy-dotnet-server = pkgs.buildDotnetGlobalTool {
      pname = "dotnet-easydotnet";
      nugetName = "EasyDotnet";
      version = "3.1.3";
      nugetHash = "sha256-MasiP8L7t/wvUX2azAqG9DxLezr2nNl2DA0ZUKbnPD8=";

      meta = {
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

