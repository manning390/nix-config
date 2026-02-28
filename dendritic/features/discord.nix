{
  flake.aspects.discord.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # discord-canary
      discord
    ];
  };
}
