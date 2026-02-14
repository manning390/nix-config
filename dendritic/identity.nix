{lib, ...}: {
  options.local.identity = lib.mkOption {
    type = lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "System username";
        };
        email = lib.mkOption {
          type = lib.types.str;
          description = "User email";
        };
        fullName = lib.mkOption {
          type = lib.types.str;
          description = "User full name";
        };
      };
    };
    default = {};
    description = "User identity information";
  };

  config.local.identity = {
    username = "pch";
    email = "Michael Manning";
    fullName = "Michael Manning";
  };
}
