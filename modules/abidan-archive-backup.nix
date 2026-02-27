{
  config,
  lib,
  vars,
  pkgs,
  ...
}: let
  serviceName = "abidan-archive-backup";
  username = vars.username;
in {
  options.local.${serviceName}.enable = lib.mkEnableOption "Enables a user service that backs up the mysql database on the abidan archive";

  config = lib.mkIf config.local.${serviceName}.enable {
    sops.secrets.abidan_db = {
      owner = username;
    };

    systemd.user.services.${serviceName} = {
      enable = true;
      after = ["network.target" "sops-nix.service"];
      description = "MySql Backup Service for Abidan Archive";
      serviceConfig.Type = "oneshot";
      environment = {
        SERVER = "abidan"; # Found within .ssh/config
        DB_USER = "abidan";
        DB_NAME = "abidan";
        REMOTE_PATH = "~/backups";
        LOCAL_PATH = "/home/${username}/code/server/iteration110/backups";
        SSH_CONFIG = "/home/${username}/.ssh/config";
      };
      script = ''
        FILE="$(date +%Y-%m-%d_%H-%M-%S).sql"
        DB_PWD=$(cat ${config.sops.secrets.abidan_db.path})
        ${pkgs.openssh}/bin/ssh -F $SSH_CONFIG $SERVER "mysqldump -u $DB_USER -p'$DB_PWD' $DB_NAME > $REMOTE_PATH/$FILE"
        ${pkgs.openssh}/bin/scp -F $SSH_CONFIG $SERVER:$REMOTE_PATH/$FILE $LOCAL_PATH/$FILE
        ${pkgs.openssh}/bin/ssh -F $SSH_CONFIG $SERVER "rm -f $REMOTE_PATH/$FILE && php current/artisan notify-backup '$FILE ${config.networking.hostName}'"
        cd $LOCAL_PATH && ls -t -1 | tail -n +4 | xargs -r rm
      '';
    };

    systemd.user.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      after = ["network.target" "sops-nix.service"];
      timerConfig = {
        OnCalendar = "*-*-* 01:00:00";
        Persistent = true;
      };
    };
  };
}
