# My NixOS configurations

Personal NixOS configurations for multiple machines, organized as dendritic modules under `dendritic/`.

Host definitions live in `dendritic/hosts/<type>/<hostname>/default.nix`.
Shared host configuration is assembled in `dendritic/hosts/default.nix`.

This configuration is a perpetual work in progress.

## Documentation

See the [documentation](docs/index.md) for setup guides and operational procedures.

## TODO
- [x] Dendritic
    - [x] Convert all non-dendritic modules to dendritic
    - [x] Convert hosts to new dendritic style
    - [x] Clean up old files
- [ ] Nvim
    - [x] Convert nvim to use nixpkgs instead of lazy.nvim for plugins (solution slightly bespoke)
    - [ ] Setup dap with nvim for debugger
    - [x] Setup refactoring plugin for nvim
    - [x] Setup c# env on nvim
- [x] Set up auto ssh via nix-private
- [ ] Finish homelab modules
    - [x] immich
    - [x] clip
    - [x] git
    - [x] samba
    - [?] arr
    - [x] backups
- [x] ISO generation, playbook for new hosts
- [ ] Setup impermanence on all hosts
- [ ] Setup non-destructive disko on all hosts
    - [ ] Adjust nix store size on sentry
