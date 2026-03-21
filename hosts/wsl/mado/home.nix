{lib, inputs, ...}: {
  imports = builtins.map lib.custom.relativeToRoot [
    "home/core"
  ] ++ [
  ];

  # local.ssh.hosts = ["pch@sentry" "pch@glaciem"];

  home.stateVersion = "25.05";
}
