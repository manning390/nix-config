{
  flake.aspects = {aspects,...}: {
    desktop = {
      description = "A collection of aspects for a desktop machine.";

      includes = with aspects; [
        audio
        browsers
        usbdrives
      ];
    };
  };
}
