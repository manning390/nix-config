{
  pkgs,
  lib,
  config,
  ...
}: let
  git-wrapper = pkgs.writeShellScriptBin "git-wrapper" /*bash*/ ''
    function isWinDir {
      case $PWD/ in
        /mnt/*) return $(true);;
        *) return $(false);;
      esac
    }
    function git-wsl {
      if isWinDir
      then
        git.exe "$@"
      else
        ${pkgs.git} "$@"
      fi
    }
    git-wsl
  '';
in {
  config = lib.mkIf config.custom.wsl.enable {
    environment.shellAliases.git = lib.getExe git-wrapper;
  };
}
