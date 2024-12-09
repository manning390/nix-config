{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot_4
    gdtoolkit_4
    aseprite
  ];
}
