{
  flake.aspects.godot = {
    description = "Game development framework and related tools";

    nixos = {pkgs, ...}: {
      environment = {
        sessionVariables = {
          GODOT = "1";
        };

        systemPackages = with pkgs; [
          godot_4
          gdtoolkit_4
          aseprite
        ];
      };
    };
  };
}
