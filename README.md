# My NixOS configurations

## Concepts
These concepts are layers onto themselves, read top > down.

- [Flakes](https://nix.dev/concepts/flakes.html) - experimental solution to versioning
- [sops-nix](https://github.com/Mic92/sops-nix) - secret management
- [Flake Parts](https://flake.parts/index.html) - solution to systems problem, modularize flake file
- [Dendritic System](https://github.com/Doc-Steve/dendritic-design-with-flake-parts) - every config is a flake-part module and can be organized trivially, enables multi-class module configs
- [flake-file](https://github.com/vic/flake-file) - Generate flake via configs, keep input requirements close to config
- [flake-aspects](https://github.com/vic/flake-aspects) - Inverts host-to-feature relationship. Features now specify hosts. What, not, where.

## TODO
- [ ] Dendritic
    - [ ] Convert all non-dendritic modules to dendritic
    - [ ] Convert hosts to new dendritic style
    - [ ] Reorganize dendritic folder and rename to modules
- [ ] Nvim
    - [ ] Convert nvim to use nixpkgs via wrapper?
    - [ ] Setup dap with nvim for debugger
    - [ ] Setup refactoring plugin for nvim
    - [ ] Setup c# env on nvim
- [ ] Set up auto ssh via nix-private
- [ ] Finish homelab modules
    - [ ] immich
    - [ ] clip
    - [ ] git
    - [ ] backups
    - [ ] arr?
- [ ] Setup impermanence on all hosts
- [ ] Setup non-destructive disko on all hosts
