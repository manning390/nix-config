{
  lib,
  inputs,
  pkgs,
  plugins,
}: let
  enabledPlugins = plugins |> lib.filterAttrs (_: plugin: plugin.enable);
  declarations = builtins.attrValues enabledPlugins;
  luaSpecs =
    declarations
    |> map (p: p.lua)
    |> builtins.filter (lua: lua != "")
    |> lib.concatStringsSep ",\n";

  resolve = name: declaration:
    assert lib.assertMsg ((declaration.package != null) != (declaration.input != null))
    "Neovim plugin '${name}' must declare exactly one of package or input."; let
      dependencies = declaration.dependencies pkgs;
      package =
        if declaration.input != null
        then
          pkgs.vimUtils.buildVimPlugin {
            pname = declaration.input;
            version = inputs.${declaration.input}.shortRev or "locked";
            src = inputs.${declaration.input};
          }
        else if builtins.isString declaration.package
        then pkgs.vimPlugins.${declaration.package}
        else declaration.package pkgs;
    in {
      inherit (declaration) optional;
      plugin = package.overrideAttrs (old:
        lib.optionalAttrs (dependencies != []) {
          dependencies = (old.dependencies or []) ++ dependencies;
        }
        // declaration.overrideAttrs old);
    };
in {
  packages = lib.mapAttrsToList resolve enabledPlugins;
  extraPackages = lib.concatMap (p: p.extraPackages pkgs) declarations;
  runtimePaths = lib.concatMap (p: p.runtimePaths pkgs) declarations;
  lua =
    # lua
    ''
      -- Generated from local.nvim.plugins; edit the individual plugin Nix modules.
      return {
        ${luaSpecs}
      }
    '';
}
