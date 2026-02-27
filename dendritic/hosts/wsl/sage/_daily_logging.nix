# home-manager class
{pkgs, osConfig, ...}: let
  username = osConfig.local.identity.username;
in {
  home.packages = [
    (pkgs.writeShellScriptBin "daily"
      /* bash */
      ''
        DATE=$(date +%F)
        DAILY_DIR="/home/${username}/Daily"
        if [ ! -f "$DAILY_DIR/$DATE.md" ]; then
          cp "$DAILY_DIR/template.md" "$DAILY_DIR/$DATE.md"
          sed "1s/DATE/$DATE/" "$DAILY_DIR/$DATE.md" -i
        fi
        vi "$DAILY_DIR/$DATE.md"
      '')
  ];
}
