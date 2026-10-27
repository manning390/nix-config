{
  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/NixOS-WSL/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects = {aspects, ...}: {
    wsl = {
      includes = with aspects; [wsl-git-wrapper wezterm];

      nixos = {
        inputs,
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [inputs.nixos-wsl.nixosModules.wsl];

        options.local.wsl.windowsUser = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Windows username for this WSL host.";
        };

        config = {
          assertions = [
            {
              assertion = config.local.wsl.windowsUser != "";
              message = "local.wsl.windowsUser must be set for WSL hosts.";
            }
          ];

          wsl.enable = true;
          wsl.defaultUser = config.local.identity.username;
          environment.systemPackages = [pkgs.wsl-open];
          environment.shellAliases.open = "explorer.exe";
          networking.networkmanager.enable = false;
        };
      };

      homeManager = {
        config,
        lib,
        osConfig,
        ...
      }: {
        # Treat the Windows home as a default launch directory, without
        # overriding explicit working directories. Run before last-working-dir.
        programs.zsh.initContent = lib.mkIf config.programs.zsh.enable (lib.mkOrder 900 ''
          if [[ "$PWD" == ${lib.escapeShellArg "/mnt/c/Users/${osConfig.local.wsl.windowsUser}"} ]]; then
            builtin cd -- "$HOME"
          fi
        '');
      };
    };
  };
}
