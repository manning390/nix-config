{
  self,
  inputs,
  constants
}: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  vars = import ./vars.nix;
  vars_networking = import ./vars_networking.nix {inherit lib;};

  specialArgsForSystem = system:
    {
      inherit (constants) username usernamefull useremail;
      inherit mylib vars_networking;

      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # All unstable packages can be unfree
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
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
    vars
    {inherit self lib mylib allSystemSpecialArgs;}
  ];
in 
  mylib.attrs.mergeAttrsList [
    (import ./nixos.nix args)
  ]
