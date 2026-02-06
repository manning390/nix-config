{
  pkgs,
  lib,
  ...
}: let
  git-wrapper = pkgs.writeShellScriptBin "git-wrapper" ''
    #!/usr/bin/env bash
    set -euo pipefail

    isWinDir() {
      case "$PWD"/ in
        /mnt/*) return 0 ;;
        *)      return 1 ;;
      esac
    }

    git-wsl() {
      if isWinDir; then
        git.exe "$@"
      else
        ${lib.getExe pkgs.git} "$@"
      fi
    }

    git-wsl "$@"
  '';
in {
  programs.git.enable = true;

  home.packages = [
    git-wrapper
  ];

  home.shellAliases.git = lib.getExe git-wrapper;
}
