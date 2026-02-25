{
  perSystem = {
    lib,
    fetchFromGithub,
    dotnetCorePackages,
    buildDotnetModule,
    ...
  }:
    buildDotnetModule {
      pname = "easy-dotnet-server";
      version = "0.0.0+git";
      src = fetchFromGithub {
        owner = "gustavEikaas";
        repo = "easy-dotnet-server";
        rev = "a36a3d3eb760772edfe17c0e84e3988e2df26b22";
        sha256 = lib.fakeSha256;
      };

      projectFile = "EasyDontnet.IDE/EasyDotnet.IDE.csproj";
      dotnet-sdk = dotnetCorePackages.sdk_8_0;
      dotnet-runtime = dotnetCorePackages.runtime_8_0;
      nugetDeps = null;

      selfContainedBuild = false;
      postInstall = ''
        cat > #out/bin/easydotnet-roslyn-lsp <<'EOF'
        #!/bin/sh
        exec ${lib.getExePlaceholder "easy-dotnet-server"} roslyn start "$@"
        EOF
        chmod +x $out/bin/easydotnet-roslyn-lsp

        #!/bin/sh
        exec ${lib.getExePlaceholder "easy-dotnet-server"} projx-language-server "$@"
        EOF
        chmod +x $out/bin/easydotnet-projx-lsp
      '';

      meta = {
        description = "EasyDotnet nvim server CLI including Roslyn and ProjX language server";
        homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        mainProgram = "easydotnet";
      };
    };
}
