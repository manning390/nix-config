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

new-hardware hostname *args:
  ./scripts/generate-hardware.sh "{{hostname}}" {{args}}

# Collect this host's hardware and refresh its documentation entry.
document-host:
  bash ./scripts/document-host.sh

# Build an installer ISO using a configured NixOS host as its source.
build-iso host:
  nixos-rebuild build-image --flake ".#{{host}}" --image-variant iso-installer

deploy host:
  nix develop -c deploy .#{{host}}

deploy-dry host:
  nix develop -c deploy --dry-activate .#{{host}}
