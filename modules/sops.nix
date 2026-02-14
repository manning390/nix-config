{
  inputs,
  config,
  lib,
  vars,
  pkgs,
  ...
}: let
  home = "/home/${vars.username}";
  hostname = config.networking.hostName;
  host_key_file = "/etc/ssh/host_${hostname}_ed25519_key";
  user_key_file = "${home}/.ssh/user_${vars.username}_${hostname}_ed25519_key";
in {
  # Get sops from flake input
  imports = [inputs.sops-nix.nixosModules.sops];

  options.custom.sops = {
    enable = lib.mkEnableOption "enables sops";
    homeOnSeparatePartition = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set to true if /home is a separate partition and needs to be enabled on boot for sops to access.
      '';
    };
    generateKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Will create ssh keys if they do not exist, may conflict with impermanence.
      '';
    };
  };

  config = lib.mkIf config.custom.sops.enable {
    # Include required packages to run scripts and work with secrets
    environment.systemPackages = with pkgs; [openssh sops ssh-to-age];

    sops = {
      defaultSopsFile = lib.custom.relativeToRoot "secrets/secrets.yaml";
      defaultSopsFormat = "yaml";
      validateSopsFiles = false;

      age = {
        # automatically import host SSH keys as age keys
        sshKeyPaths = [host_key_file];
        # this will use an age key that is expected to already be in the filesystem
        keyFile = "/var/lib/sops-nix/key.txt";
        # generage a new key if the key specified above does not exist
        generateKey = true;
      };
    };

    fileSystems = lib.mkIf config.custom.sops.homeOnSeparatePartition {
      "/home".neededForBoot = true;
    };

    system.activationScripts = lib.mkIf config.custom.sops.generateKeys {
      generateSSHKeys.text = let
        sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
      in ''
        # Generate host ssh key if missing
        if [ ! -f "${host_key_file}" ]; then
          ${sshKeygen} -t ed25519 -N "" -C "host key ${hostname} $(date +%s)" -f "${host_key_file}"
          chmod 600 ${host_key_file}
          chmod 644 ${host_key_file}.pub
        fi
      '';
      # # Generate user key if missing
      # if [ ! -f "${user_key_file}" ]; then
      #   mkdir -p "${home}/.ssh"
      #   ${sshKeygen} -t ed25519 -N "" -C "user key ${vars.username}@${vars.hostname} $(date +%s)" -f "${user_key_file}"
      #   chown -R ${vars.username}:${vars.username} "${home}/.ssh"
      #   chmod 700 "${home}/.ssh"
      #   chmod 600 "${user_key_file}"
      #   chmod 644 "${user_key_file}.pub"
      # fi
    };
  };
}
