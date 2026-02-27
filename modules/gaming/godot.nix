{pkgs, ...}: {
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
  
}
