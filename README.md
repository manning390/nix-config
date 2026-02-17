# My NixOS configurations

## Concepts
These concepts are layers onto themselves, read top > down.

- [Flakes](https://nix.dev/concepts/flakes.html) - experimental solution to versioning
- [sops-nix](https://github.com/Mic92/sops-nix) - secret management
- [Flake Parts](https://flake.parts/index.html) - solution to systems problem, modularize flake file
- [Dendritic System](https://github.com/Doc-Steve/dendritic-design-with-flake-parts) - every config is a flake-part module and can be organized trivially, enables multi-class module configs
- [flake-file](https://github.com/vic/flake-file) - Generate flake via configs, keep input requirements close to config
- [flake-aspects](https://github.com/vic/flake-aspects) - Inverts host-to-feature relationship. Features now specify hosts. What, not, where.
