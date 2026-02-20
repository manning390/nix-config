{
  flake.identity = {
    username = "pch";
    email = "michael@manning390.com";
    fullName = "Michael Manning";
  };
  flake.aspects.identity = {
    nixos = {inputs, lib, ...}: {
      options.local.identity = {
        username = lib.mkOption {
          type = lib.types.singleLineStr;
          default = inputs.self.identity.username;
          description = "System username (Nixos level, defaults from flake-parts)";
        };
        email = lib.mkOption {
          type = lib.types.singleLineStr;
          default = inputs.self.identity.email;
          description = "User email (Nixos level, defaults from flake-parts)";
        };
        fullName = lib.mkOption {
          type = lib.types.singleLineStr;
          default = inputs.self.identity.fullName;
          description = "User full name (Nixos level, defaults from flake-parts)";
        };
      };
    };
  };
}
