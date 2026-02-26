{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.easy-dotnet-server = pkgs.buildDotnetGlobalTool {
      pname = "easy-dotnet-server";
      version = "unstable-2026-02-26";
      nugetHash = lib.fakeSha256;

      meta = {
        description = "EasyDotnet CLI including Roslyn and ProjX language server";
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

