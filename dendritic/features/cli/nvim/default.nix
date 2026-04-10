{self,...}: {
    flake.perSystem = {inputs, lib, pkgs, system,...}: let
        nixPatch = inputs.nixPatch;
    in {
        packages.nvimNixPatched = nixPatch.configWrapper.${system} { 
            name = "nixPatch";
            extra_pkg_config = {};
            configuration = {pkgs,...}: {
                aliases = [ "vim" "vi" ];
                luaPath = ./.;
                runtimeDeps = with pkgs; [
                    ripgrep
                    fzf

                    gcc
                    gnumake
                    nodejs
                    pnpm
                    # intelephense
                    python3
                    cmake
                    ninja

                    tree-sitter
                    cmake-language-server
                    lua-language-server
                    neovim-node-client
                    nodePackages.typescript
                    nodePackages.typescript-language-server
                    nodePackages.eslint
                    eslint_d
                    efm-langserver
                    nixd
                    ajelandra
                    vale-ls
                ];
                plugins = import ./_plugins.nix { inherit pkgs; };
                customSubs = with nixPatch.patchUtils.${system}; [];
                    # For example, if you want to add a plugin with the short url
                    # "cool/plugin" which is in nixpkgs as plugin-nvim you would do:
                    # ++ (patchUtils.githubUrlSub "cool/plugin" plugin-nvim);
                    # If you would want to replace the string "replace_me" with "replaced" 
                    # you would have to do:
                    # ++ (patchUtils.stringSub "replace_me" "replaced")
                    # For more examples look here: https://github.com/NicoElbers/nixPatch-nvim/blob/main/subPatches.nix
                settings = {
                    defaultEditor = true;

                    withNodeJs = true;
                    withPython3 = true;

                    patchSubs = true;
                    suffix-path = false;
                    suffix-LD = false;
                };

            };
        };
    };

    flake.aspects.nvim = {
        nixos = {pkgs,...}: let
            system = pkgs.stdenv.hostPlatform.system;
        in {
            environment.systemPackages = [self.packages.${system}.nvimNixPatched];
        };
        homeManager = {pkgs, ...}: let
            system = pkgs.stdenv.hostPlatform.system;
        in {
            imports = [ ];

            home.packages = [
              pkgs.devenv
              pkgs.ripgrep
              self.packages.${system}.nvimNixPatched
            ];

            programs.direnv.enable = true;

            home.sessionVariables = {
              EDITOR = "nvim";
              VISUAL = "nvim";
              SUDO_EDITOR = "nvim";
              DIRENV_LOG_FORMAT = "";
            };
        };
    };
}
