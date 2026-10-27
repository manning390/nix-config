{
  flake.modules.flake.nvim-options = {lib, ...}: {
    options.local.nvim.plugins = lib.mkOption {
      default = {};
      description = "Neovim plugins contributed by individual flake modules.";

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this Neovim plugin" // {default = true;};

          package = lib.mkOption {
            type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.functionTo lib.types.package));
            default = null;
            description = "A vimPlugins attribute name, or a function from plugin pkgs to a package.";
          };

          input = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "A flake-file source input to build as a Vim plugin, instead of package.";
          };

          dependencies = lib.mkOption {
            type = lib.types.functionTo (lib.types.listOf lib.types.package);
            default = _: [];
            description = "Additional plugin dependencies, resolved with the editor's plugin package set.";
          };

          overrideAttrs = lib.mkOption {
            type = lib.types.functionTo lib.types.attrs;
            default = _: {};
            description = "Optional derivation overrides for native builds or patches.";
          };

          optional = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Install as an optional package for lze to load.";
          };

          lua = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "One Lua lze spec, with optional explicit main and opts convenience fields.";
          };

          extraPackages = lib.mkOption {
            type = lib.types.functionTo (lib.types.listOf lib.types.package);
            default = _: [];
            description = "Executable packages needed by this plugin.";
          };

          runtimePaths = lib.mkOption {
            type = lib.types.functionTo (lib.types.listOf lib.types.package);
            default = _: [];
            description = "Additional runtime paths, such as Nix-built Treesitter parsers.";
          };
        };
      });
    };
  };
}
