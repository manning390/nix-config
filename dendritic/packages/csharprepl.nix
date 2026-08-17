{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.csharprepl = pkgs.buildDotnetGlobalTool {
      pname = "csharprepl";
      nugetName = "CSharpRepl";
      version = "0.9.2";

      dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
      # We're using an SDK here because it's a REPL, and it requires an SDK instead of a runtime
      dotnet-runtime = pkgs.dotnetCorePackages.sdk_10_0;

      nugetHash = "sha256-u3MwRmY9kPWUd3k8zD3sDLeND8vqtHFx8xSPWCEvink=";

      meta = {
        description = "C# REPL with syntax highlighting";
        homepage = "https://fuqua.io/CSharpRepl";
        changelog = "https://github.com/waf/CSharpRepl/blob/main/CHANGELOG.md";
        license = lib.licenses.mpl20;
        platforms = lib.platforms.unix;
        maintainers = with lib.maintainers; [_4evy];
        mainProgram = "csharprepl";
      };
    };
  };
}
