{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.colemak_dhm.enable = lib.mkEnableOption "enables colemak_dhm remaps";
  config = lib.mkMerge [
    (lib.mkIf config.local.colemak_dhm.enable {
      services.xserver.xkb = {
        layout = "colemak_dhm,us";
        options = "caps:escape,grp:alt_shift_toggle";

        # Create the colemak-dhm layout
        extraLayouts.colemak_dhm = {
          description = "Colemak-DHm";
          languages = ["eng"];
          symbolsFile = pkgs.writeText "colemak_dhm" ''
            xkb_symbols "colemak_dhm" {
                include "us(colemak)"

                name[Group1]= "English (Colemak-DHm)";

                key <AD05> { [ b, B ] };
                key <AD06> { [ j, J ] };
                key <AD07> { [ l, L ] };
                key <AD08> { [ u, U ] };
                key <AD09> { [ y, Y ] };

                key <AC03> { [ s, S ] };
                key <AC04> { [ t, T ] };
                key <AC05> { [ g, G ] };
                key <AC06> { [ m, M ] };
                key <AC07> { [ n, N ] };
                key <AC08> { [ e, E ] };
                key <AC09> { [ i, I ] };
                key <AC10> { [ o, O ] };

                key <AB02> { [ x, X ] };
                key <AB03> { [ c, C ] };
                key <AB04> { [ d, D ] };
                key <AB05> { [ v, V ] };
                key <AB06> { [ k, K ] };
                key <AB07> { [ h, H ] };
            };
          '';
        };
      };
    })
    (lib.mkIf (!config.local.colemak_dhm.enable) {
      services.xserver.xkb = {
        layout = "us";
        options = "caps:escape";
      };
    })
    {
      console.useXkbConfig = true;
    }
  ];
}
