# My NixOS configurations

## Mind the dust?
Currently in the middle of a migration. Everything will eventually live in `./dendritic`, outside of that is somewhat deprecated.

Entry point for systems is `hosts/<system>/<hostname/default.nix` which sets options for `hosts/default.nix` to consume.

## Concepts
These concepts are layers onto themselves, read top > down.

- [Flakes](https://nix.dev/concepts/flakes.html) - Experimental (ha!) solution to versioning
- [sops-nix](https://github.com/Mic92/sops-nix) - Secret management
- [Flake Parts](https://flake.parts/index.html) - Solution to systems problem, modularize flake file
- [Dendritic System](https://github.com/Doc-Steve/dendritic-design-with-flake-parts) - Every config is a flake-part module and can be organized trivially, enables multi-class module configs
- [flake-file](https://github.com/vic/flake-file) - Generate flake file via configs, keep input requirements and definitions close to config
- [flake-aspects](https://github.com/vic/flake-aspects) - Inverts host-to-feature relationship. Features now specify hosts. What, not, where.

## TODO
- [ ] Dendritic
    - [ ] Convert all non-dendritic modules to dendritic
    - [x] Convert hosts to new dendritic style
- [ ] Nvim
    - [ ] Convert nvim to use nixpkgs via wrapper?
    - [ ] Setup dap with nvim for debugger
    - [ ] Setup refactoring plugin for nvim
    - [x] Setup c# env on nvim
- [x] Set up auto ssh via nix-private
- [ ] Finish homelab modules
    - [ ] immich
    - [ ] clip
    - [x] git
    - [ ] backups
    - [ ] arr?
    - [x] samba
- [ ] Setup impermanence on all hosts
- [ ] Setup non-destructive disko on all hosts
