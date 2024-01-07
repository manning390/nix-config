{
  username,
  config,
  ...
}: {
  # Don't allow mutation of users outside this config
  users.mutableUsers = false;

  # Specify additional groups here
  users.groups = {
    "${username}" = {};
    docker = {};
  };

  # Setup the only user
  users.users."${username}" = {
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = [
      username
      "users"
      "networkmanager"
      "wheel"
      "docker"
      "audio"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = config.users.users."${username}".openssh.authorizedKeys.keys;
  };

  # DO NOT promote the specified user to input password for `nix-store` and `nix-copy-closure`
  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-copy-closure";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
