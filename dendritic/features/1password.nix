{
  # underscore because starting with digit is invalid nix
  flake.aspects._1password = {
    description = "Password Vault CLI and Desktop clients";

    nixos = {config, ...}: let
      user = config.local.identity.username;
    in {
      # These are unfree, by default I allow unfree
      # Setting is in base/nix aspect
      programs = {
        _1password.enable = true;
        _1password-gui = {
          enable = true;
          polkitPolicyOwners = [ user ];
        };
      };
    };
  };
}
