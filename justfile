alias fmt := format
alias c := check
alias b := build

# Format nix files
format:
  nix fmt

# Check if flake compiles
check:
  nix flake check

build:
  nh os switch .

update:
  nh os switch . --update

new command *args:
  @just new-{{command}} {{args}}

new-host *args:
  ./scripts/generate-host.sh {{args}}
