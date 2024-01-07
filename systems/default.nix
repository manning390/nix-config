{
  self,
  inputs,
  constants
}: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  linked = import ./linking.nix;

  specialArgsForSystem = system:
    {
      inherit (constants) username usernamefull useremail;
      inherit mylib;

      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # All unstable packages can be unfree
        config.allowUnfree = true;
      };
    }
    // inputs;

  allSystemSpecialArgs =
    mylib.attrs.mapAttrs
    (_: specialArgsForSystem)
    constants.allSystemAttrs;

  args = mylib.attrs.mergeAttrsList [
    inputs
    constants
    linked
    {inherit self lib mylib allSystemSpecialArgs;}
  ];
in 
  mylib.attrs.mergeAttrsList [
    (import ./nixos.nix args)
  ];
