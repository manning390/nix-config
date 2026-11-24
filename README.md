# My NixOS configurations

Personal NixOS configurations for multiple machines, organized as dendritic modules under `dendritic/`.

Host definitions live in `dendritic/hosts/<type>/<hostname>/default.nix`.
Shared host configuration is assembled in `dendritic/hosts/default.nix`.

This configuration is a perpetual work in progress.

## Documentation

See the [documentation](docs/index.md) for setup guides and operational procedures.

## TODO
- [ ] Keybindings
    - [x] First pass: selected Caelestia/dwindle bindings, pickers and reference
    - [ ] Test the first pass on Sentry and Ruby (Super+? opens the reference)
    - [ ] Second pass: ???
    - [ ] Experiment with workspace groups and multiple monitors; do not change current 1–10 numbering yet
    - [ ] Review deferred items in the temporary `keybind-review.md`
- [x] Dendritic
    - [x] Convert all non-dendritic modules to dendritic
    - [x] Convert hosts to new dendritic style
    - [x] Clean up old files
- [x] Nvim
    - [x] Convert nvim to use nixpkgs instead of lazy.nvim for plugins (solution slightly bespoke)
    - [x] Setup dap with nvim for debugger
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

## Black display / lock recovery

Sentry intentionally disables suspend; screen blanking is separate from suspend.
For a black or unresponsive lock screen, first try switching to a text console
with Ctrl+Alt+F3, then back to the graphical console (often Ctrl+Alt+F1 or F2).
If needed, log in on the text console as the desktop user:

```sh
hyprctl instances
# Substitute the instance signature from the output:
hyprctl -i INSTANCE dispatch dpms on
systemctl --user status caelestia.service
journalctl --user -b -u caelestia.service -n 100
```

If Caelestia has crashed or is unresponsive, an authenticated TTY login can run
`systemctl --user restart caelestia.service`. This is not an unlock command:
restarting a session-lock client may leave the compositor locked. Avoid repeatedly
restarting it, killing the lock, or adding unauthenticated unlock shortcuts.
If recovery fails, save logs before ending the graphical session; ending it loses
unsaved application work. A machine that cannot switch TTYs may have a GPU/resume
problem rather than just a shell problem.
