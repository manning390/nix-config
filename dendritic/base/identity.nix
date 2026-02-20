{
  lib,
  ...
}: {
  options.local.identity = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "pch";
      description = "System username";
    };
    email = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "michael@manning390.com";
      description = "User email";
    };
    fullName = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "Michael Manning";
      description = "User full name";
    };
  };
}
