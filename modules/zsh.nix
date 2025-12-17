{pkgs, vars, ...}: {
  environment.shells = [pkgs.zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users."${vars.username}".shell = pkgs.zsh;
}
