{lib, ...}: {
  flake.modules.identity = {
    nixos = {
      options.local.identity = {
        username = lib.mkOption {
          type = lib.types.str;
          default = "pch";
          description = "System username";
        };
        email = lib.mkOption {
          type = lib.types.str;
          default = "michael@manning390.com";
          description = "User email";
        };
        fullName = lib.mkOption {
          type = lib.types.str;
          default = "Michael Manning";
          description = "User full name";
        };
      };
    };
  };
}
