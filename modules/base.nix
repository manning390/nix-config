{
  username,
  userfullname,
  ...
} @ args: {
  users.users.${username} = {
    description = userfullname;
    openssh.authorized.keys = [];
  };

  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    trusted-users = [username];

    substituters = [];
    trusted-public-keys = [];
    builders-use-substitues = false;
  };
}
