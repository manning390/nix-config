{lib, inputs, ...}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "home/core"
  ] ++ [
    # inputs.nix-private.homeManagerModules
  ];

  # local.ssh.hosts = ["pch@sentry" "pch@glaciem"];

  home.stateVersion = "25.05";
}
