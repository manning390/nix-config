{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        just
        nixos-rebuild
        inputs.deploy-rs.packages.${system}.default
      ];
    };
    formatter = pkgs.writeShellScriptBin "alejandra" ''
      exec ${pkgs.alejandra}/bin/alejandra --quiet "$@"
    '';
  };
}
