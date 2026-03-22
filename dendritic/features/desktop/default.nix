{
  flake.aspects = {aspects,...}: {
    desktop = {
      description = "A collection of aspects for a desktop machines.";

      includes = with aspects; [
        audio
        browsers
        usbdrives
      ];
    };
  };
}
