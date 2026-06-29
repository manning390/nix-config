{
  flake.aspects.audio = {
    nixos = {pkgs, ...}: {
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.systemPackages = with pkgs; [
        headsetcontrol # minor support for G733 Logi headset
        ncpamixer # Audio levels cli
      ];

      environment.shellAliases = {
        sound = "ncpamixer";
        led = "headsetcontrol -l 0";
      };
    };
  };
}
