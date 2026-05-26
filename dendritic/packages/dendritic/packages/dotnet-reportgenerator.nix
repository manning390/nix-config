{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.dotnet-reportgenerator = pkgs.buildDotnetGlobalTool {
      pname = "reportgenerator";
      nugetName = "dotnet-reportgenerator-globaltool";
      version = "5.5.7";
      nugetHash = "sha256-wE6uNigiKG87+Hg4U1/yU8JNjwu+PYra+f2pu0Ou3kg=";

      meta = {
        homepage = "https://github.com/danielpalme/ReportGenerator";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

