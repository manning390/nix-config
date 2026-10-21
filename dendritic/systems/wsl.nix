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
          environment.shellAliases.open = "explorer.exe";
          networking.networkmanager.enable = false;
        };
      };
      homeManager = {};
    };
  };
}
