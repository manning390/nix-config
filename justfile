alias fmt := format
alias c := check
alias b := build

# Format nix files
format:
  nix fmt

# Check if flake compiles
check:
  nom flake check

build:
  nh os switch ~/Code/nix/nix-config/

update:
  nh os switch ~/Code/nix/nix-config/ --update
