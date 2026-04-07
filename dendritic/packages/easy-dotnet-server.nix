{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.easy-dotnet-server = pkgs.buildDotnetGlobalTool {
      pname = "dotnet-easydotnet";
      nugetName = "EasyDotnet";
      version = "3.0.0";
      nugetHash = "sha256-olaARuN/RErqyZAIiDeHZlYAxlNM/Qfn6wk73nfRBjM=";

      meta = {
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
  };
}

