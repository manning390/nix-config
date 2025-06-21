{vars, ...}: let
  home = "/home/${vars.username}";
in
 {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${home}/.config/sops/age/keys.txt";
  };
  fileSystems."/home".neededForBoot = true;

  system.activationScripts.generateSSHKeys.text =
  let
      host_key_file = "/etc/ssh/host_${vars.hostname}_ed25519_key";
      user_key_file = "${home}/.ssh/user_${vars.username}_${vars.hostname}_ed25519_key";
  in
    ''
    # Generate host ssh key if missing
    if [ ! -f "${host_key_file}" ]; then
      ssh-keygen -t ed25519 -N "" -C "host key ${vars.hostname} $(date +%s)" -f "${host_key_file}"
      chmod 600 ${host_key_file}
      chmod 644 ${host_key_file}.pub
    fi

    # Generate user key if missing
    if [ ! -f "${home}/.ssh/${user_key_file}" ]; then
      mkdir -p "/${home}/.ssh"
      ssh-keygen -t ed25519 -N "" -C "user key ${vars.username}@${vars.hostname} $(date +%s)" -f "${home}/.ssh/${user_key_file}"
      chown -R ${vars.username}:${vars.username}"${home}/.ssh"
      chmod 700 "${home}/.ssh"
      chmod 600 "${home}/.ssh/${user_key_file}"
      chmod 644 "${home}/.ssh/${user_key_file}.pub"
    fi
  '';
}
