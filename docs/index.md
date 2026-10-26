# Documentation

## In This Repo

| Document | Covers |
| --- | --- |
| [Host inventory](hosts.md) | Host type, description, and hardware collected with `just document-host`. |
| [Host setup](new-host-playbook.md) | Add hosts, build installer ISOs, and install or reinstall NixOS. |
| [Homelab backups](backups.md) | Configure passwords, run backups, copy off-site, and restore data. |
| [Media stack](media-stack.md) | Connect Deluge, Prowlarr, Sonarr, Radarr, Bazarr, Jellyfin, and Seerr. |
| [OpenCode backups](opencode-backups.md) | Sage's weekday session backups and how to restore them. |

## Configuration Design Concepts
These concepts are layers onto themselves, read top > down.

- [Flakes](https://nix.dev/concepts/flakes.html) - Experimental (ha!) solution to versioning
- [sops-nix](https://github.com/Mic92/sops-nix) - Secret management
- [Flake Parts](https://flake.parts/index.html) - Solution to systems problem, modularize flake file
- [Dendritic System](https://github.com/Doc-Steve/dendritic-design-with-flake-parts) - Every config is a flake-part module and can be organized trivially, enables multi-class module configs
- [flake-file](https://github.com/vic/flake-file) - Generate flake file via configs, keep input requirements and definitions close to config
- [flake-aspects](https://github.com/vic/flake-aspects) - Inverts host-to-feature relationship. Features now specify hosts. What, not, where.
