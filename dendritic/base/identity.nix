# This is imported both at flake level and nixos module level
{lib,...}: let 
  identity = {
    username = "pch";
    email = "michael@manning390.com";
    fullName = "Michael Manning";
  };
in {
  options.local.identity = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = identity.username;
      description = "Primary username";
    };
    email = lib.mkOption {
      type = lib.types.singleLineStr;
      default = identity.email;
      description = "User email";
    };
    fullName = lib.mkOption {
      type = lib.types.singleLineStr;
      default = identity.fullName;
      description = "User full name";
    };
  };
}
