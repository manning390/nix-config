{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.easy-dotnet-server = pkgs.buildDotnetGlobalTool {
      pname = "dotnet-easydotnet";
      nugetName = "EasyDotnet";
      version = "2.9.6";
      nugetHash = "sha256-GohjenhJRSFvN8OJX5v0tucgigba6MOcOWldEjQ0lY8=";

      meta = {
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

