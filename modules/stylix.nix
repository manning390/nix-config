{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  options.custom.stylix.enable = lib.mkEnableOption "enables stylix";
  config = lib.mkIf config.custom.stylix.enable {
    imports = [inputs.stylix.nixosModules.stylix];

    # Nord from https://github.com/ada-lovecraft/base16-nord-scheme/tree/master
    stylix = {
      enable = false;
      polarity = "dark";
      base16Scheme = {
        base00 = "2E3440";
        base01 = "3B4252";
        base02 = "434C5E";
        base03 = "4C566A";
        base04 = "D8DEE9";
        base05 = "E5E9F0";
        base06 = "ECEFF4";
        base07 = "8FBCBB";
        base08 = "88C0D0";
        base09 = "81A1C1";
        base0A = "5E81AC";
        base0B = "BF616A";
        base0C = "D08770";
        base0D = "EBCB8B";
        base0E = "A3BE8C";
        base0F = "B48EAD";
      };
      image = config.lib.stylix.pixel "base0A";
      fonts = {
        serif = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        monospace = {
          package = pkgs.nerd-fonts.fira-code-mono;
          name = "FiraCode Nerd Font Mono";
        };
        sizes.terminal = 14;
      };
    };
  };
}
