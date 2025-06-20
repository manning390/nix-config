{vars, ...}: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.username}/.config/sops/age/keys.txt";
  };
  fileSystems."/home".neededForBoot = true;
}
