{
  flake.aspects.herdr = {
    description = "Herdr terminal workspace manager for AI coding agents";

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        github-copilot-cli
        unstable.herdr
      ];
    };
  };
}
