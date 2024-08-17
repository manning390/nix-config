alias fmt := format

# Format nix files
format:
  nix fmt

# Check if flake compiles
check:
  nix flake check

rebuild:
  sudo nixos-rebuild switch --flake .#sentry
