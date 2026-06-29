{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [just nixos-rebuild];
    };
    formatter = pkgs.alejandra;
  };
}
