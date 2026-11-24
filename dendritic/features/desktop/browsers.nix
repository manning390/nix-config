{
  flake.aspects = {aspects, ...}: {
    browsers = {
      includes = [aspects.firefox];

      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          brave
        ];
      };
    };
  };
}
