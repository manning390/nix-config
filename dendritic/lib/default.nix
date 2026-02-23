
{lib, ...}: {
  options.flake.lib = lib.mkOption {
    type = with lib.types; attrsOf unspecified;
    default = {};
  };
  config.flake.lib = {
    attrs = import ../../lib/attrs.nix {inherit lib;};
    relativeToRoot = path: lib.path.append ../. path;
    # Deprecrated
    scanPaths = path:
      builtins.map
      (f: (path + "/${f}"))
      (builtins.attrNames
        (lib.attrsets.filterAttrs
          (
            path: _type:
              (_type == "directory") # include directories
              || (
                (path != "default.nix") # ignore default.nix
                && (lib.strings.hasSuffix ".nix" path) # include .nix files
              )
          )
          (builtins.readDir path)));
  };
}
