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
  nh os switch .

update:
  nh os switch . --update

new-host hostname type="nixos" aspects="":
  ./scripts/generate-host.sh {{hostname}} {{type}} {{aspects}}
