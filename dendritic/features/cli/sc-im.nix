{
  flake.aspects.sc-im = {
    description = "Spreadsheet tui with vim motions";
    nixos = {
      environment.shellAliases = {
        sheet = "sc-im";
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [ sc-im ];

      xdg.configFile."sc-im/scimrc".text = ''
        nnoremap "m" "h"
        nnoremap "n" "j"
        nnoremap "e" "k"
        nnoremap "i" "l"

        vnoremap "m" "h"
        vnoremap "n" "j"
        vnoremap "e" "k"
        vnoremap "i" "l"

        nunmap "l"
        vunmap "l"
        cnoremap "lr" "ir" 
        cnoremap "lc" "ic" 

        cnoremap "sm" "sh"
        cnoremap "sn" "sj"
        cnoremap "se" "sk"
        cnoremap "si" "sl"

        nnoremap "j" "e"
        nnoremap "J" "E"
        nnoremap "h" "n"
        nnoremap "H" "N"
        nnoremap "k" "m"
        nnoremap "K" "H"
        nnoremap "N" "J"

        enoremap "m" "h"
        enoremap "i" "l"

        enoremap "j" "i"
        enoremap "J" "I"
      '';

    };
  };
}
