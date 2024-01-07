{pkgs, lib, ...}: {
  # Add additional packages to be installed related b
  environment.systemPackages = with pkgs; [
    pulseaudio # provides pactl, required by some apps
    usbutils # provides lsusb
    libusb # provides flashing cli to ergodox
  ];

  # Sound
  services.pipewire = {
    enable = true;
    # package = pkgs-unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;
  # Remove sound.enable or turn it off if set, causes conflicts with pipewire
  sound.enable = false;
  # Disable pulseaudio, it conflicts with pipewire too.
  hardware.pulseaudio.enable = false;

  # Bluetooth
  # enable bluetooth & gui paring tools - blueman
  # or you can use cli:
  # $ bluetoothctl
  # [bluetooth] # power on
  # [bluetooth] # agent on
  # [bluetooth] # default-agent
  # [bluetooth] # scan on
  # ...put device in pairing mode and wait [hex-address] to appear here...
  # [bluetooth] # pair [hex-address]
  # [bluetooth] # connect [hex-address]
  # Bluetooth devices automatically connect with bluetoothctl as well:
  # [bluetooth] # trust [hex-address]
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # misc
  services = {
    printing.enable = true; # Enable CUPS to print documents
    geoclue2.enable = true; # Enable geolocation services

    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
    ];

    # A key remapping daemon for linux.
    # https://github.com/rvaiya/keyd
    keyd = {
      # Default to false, on nixos I'll usually have a firmware override via libusb
      enable = lib.mkDefault false;
      keyboards.default.settings = {
        main = {
          # overloads the capslock key to function as both escape (when tapped) and control (when held)
          capslock = "overload(control, esc)";
          esc = "capslock";
        };
      };
    }
  }
}
