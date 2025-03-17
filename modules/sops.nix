{myvars, ...}: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${myvars.username}/.config/sops/age/keys.txt";
  };
}
