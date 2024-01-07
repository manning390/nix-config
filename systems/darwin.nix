args:
with args;
with mylib;
with allSystemAttrs; let
  base_args = {
    inherit nix-darwin home-manager;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # MacOS's configuration
  # none atm, lol
}
