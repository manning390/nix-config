alias fmt := format
alias c := check
alias b := build

# Format nix files
format:
  nix fmt

# Check if flake compiles
check:
  @just flake
  nix flake check

build:
  @just flake
  nh os switch .

flake:
  nix run .#write-flake

update:
  @just flake
  nh os switch . --update

new command *args:
  @just new-{{command}} {{args}}

new-host *args:
  ./scripts/generate-host.sh {{args}}
