# Keybinding decisions

Temporary review file — do not commit as permanent documentation.
Editing this file does not change the live configuration.

## How to use

- Select one option per numbered section by changing `[ ]` to `[x]`.
- Recommendations are marked `recommended:` but are not preselected.
- Select `other:` and write your alternative after the colon if needed.
- Unchecked sections mean **no approval to change that area**.
- Key names mean the **typed letter**, not the letter printed on a QWERTY keycap.
- After review, we will implement the selected choices, validate them, and
  rebuild only the hosts you approve.

## Scope and existing habits

### 1. Host scope

- [x] recommended: Apply shared desktop bindings to Sentry and Ruby through the Caelestia aspect; do not change Windows/WSL keybindings.
- [ ] Apply to Sentry only initially.
- [ ] Apply to Ruby only initially.
- [ ] other:

### 2. Existing historical bindings

This is the baseline; a more specific selection below can override it.

- [ ] recommended: Preserve Super+Enter terminal, Super+D launcher, Super+C close, Super+L lock, Super+V floating, Super+P pseudotile, Super+F fullscreen, Super+T split toggle, Super+Tab previous/current window, mouse move/resize, and numbered-workspace bindings.
- [x] Review these individually before implementation; do not assume preservation is sufficient.
- [ ] other:

### 3. Colemak navigation

- [x] recommended: Preserve symbolic M/N/E/I for left/down/up/right, with Shift for window movement; retain existing dwindle arrow aliases and Ruby's symbol-based layout switching.
- [ ] Use physical-position bindings so navigation stays in the same positions when switching layouts; verify keyboard/firmware behaviour first.
- [ ] other:

### 4. Layout-specific behaviour

Both graphical hosts currently use dwindle. Scrolling already has different
Shift+arrow semantics; master lacks an equivalent directional binding group.

- [x] recommended: Limit this pass to the active dwindle setup; preserve scrolling/master configuration without redesigning it.
- [ ] Also design consistent movement bindings for scrolling and master before implementation.
- [ ] other:

## Window actions and shell utilities

### 5. Close current window

- [ ] recommended: Add Super+Q as an ordinary close-window alias; retain Super+C.
- [ ] Keep only the existing Super+C close binding.
- [x] Replace Super+C with Super+Q.
- [ ] other:

### 6. Alt+F4

Currently starts Hyprland's interactive kill mode, not ordinary close.

- [x] recommended: Preserve the existing interactive kill behaviour.
- [ ] Make Alt+F4 close the active window normally instead.
- [ ] Remove this binding.
- [ ] other:

### 7. Exit the desktop session

Currently Super+Shift+Q exits the compositor immediately.

- [x] recommended: Preserve the historical binding in this pass.
- [ ] Replace its immediate exit action with the Caelestia session menu.
- [ ] Remove the shortcut; use the session menu for logout.
- [ ] other:

### 8. Colour picker

- [x] recommended: Add Super+Shift+C to run hyprpicker -a and copy the selected colour.
- [ ] Use Super+A for colour picking instead; replace the currently broken screenshot-area binding.
- [ ] Do not add a colour-picker shortcut.
- [ ] other:

### 9. Super+A screenshot-area binding

Currently miswired as `global, caelestia:picker open`. This is not a colour
picker or a valid registered screenshot global-shortcut name.

- [ ] recommended: Correct Super+A to Caelestia's clipboard-only area picker, caelestia:screenshotClip.
- [ ] Correct Super+A to Caelestia's area picker that opens Swappy for editing.
- [ ] Remove Super+A.
- [ ] Use it for colour picking, as selected in section 8.
- [x] other: If print already is an area-selection then this keybinding is redundant and therefore remove. Otherwise if it is not, we may need to discuss further.

### 10. Session menu

- [x] recommended: Add Ctrl+Alt+Delete to open Caelestia's session menu, not immediately log out or reboot.
- [ ] Do not add a session-menu shortcut.
- [ ] other:

### 11. Sidebar

Upstream Super+N conflicts with focus down.

- [x] recommended: Add Super+Ctrl+B to toggle Caelestia's sidebar.
- [ ] Do not add a sidebar shortcut.
- [ ] other:

### 12. Show shell panels

- [x] recommended: Add Super+K to show Caelestia's panels.
- [ ] Do not add a panels shortcut.
- [ ] other:

### 13. Clear notifications

- [ ] recommended: Add Ctrl+Alt+C to clear Caelestia notifications.
- [ ] Do not add a clear-notifications shortcut.
- [x] other: Doesn't this conflict with terminal settings? Can it use super instead?

### 14. Emoji picker

- [x] recommended: Add Super+Period to open Caelestia's emoji picker.
- [ ] Do not add an emoji-picker shortcut.
- [ ] other:

## Screenshots

Prefer Caelestia where it meets the desired workflow.

- Caelestia monitor capture copies to clipboard and offers Open/Save notification actions.
- Its normal region picker opens Swappy.
- Its clipboard-only region picker copies and notifies, but has no Save action.
- Matching clipboard + optional notification Save for regions requires a small helper.
- Clipboard-first screenshots still use temporary/cache image files.

### 15. Print

- [x] recommended: Keep selected-area semantics; copy immediately and offer Save through a system notification, using a small helper around the existing capture backend.
- [ ] Keep the exact existing Grimblast selected-area clipboard behaviour.
- [ ] Use stock Caelestia clipboard-only region capture; accept no Save notification action.
- [ ] Adopt upstream Caelestia focused-monitor capture with native Open/Save notification actions; change Print from region to monitor capture.
- [ ] other:

### 16. Shift+Print

- [x] recommended: Preserve selected-area capture with immediate copy and permanent save.
- [ ] Open Caelestia's region picker into Swappy instead.
- [ ] Remove this binding and rely on notification Save actions.
- [ ] other:

### 17. Super+Print

Caelestia captures the focused monitor, not all monitors combined.

- [x] recommended: Add focused-monitor capture using Caelestia, with clipboard copy and native Open/Save notification actions.
- [ ] Do not add this binding.
- [ ] Capture all monitors together instead; implement separately.
- [ ] other:

### 18. Super+Shift+S

- [x] recommended: Add Caelestia frozen-region clipboard capture; stock mode has no Save notification action.
- [ ] Use Caelestia frozen-region capture into Swappy.
- [ ] Require clipboard copy plus a Save notification action for frozen regions too; assess additional implementation before proceeding.
- [ ] Do not add this binding.
- [ ] other:

### 19. Super+Shift+Alt+S

- [x] recommended: Add Caelestia region capture into Swappy for annotation.
- [ ] Use Caelestia non-frozen clipboard-only region capture instead.
- [ ] Do not add this binding.
- [ ] other:

### 20. Screenshot storage

This concerns new helpers; do not delete existing screenshots or caches.

- [ ] recommended: Store permanently saved screenshots under the XDG Pictures directory in a Screenshots subdirectory; keep temporary captures in user cache.
- [ ] Keep each tool's existing storage defaults.
- [x] other: Do the recommended here, but add a timer/reminder to clean/organize screenshots when there are too many (say 50?) with the expectation that they need to be saved elsewhere

## Screen recording

Caelestia commands toggle recording off when already running. Its normal
capture is the focused monitor; its sound option captures desktop/output
audio, not automatically the microphone.

### 21. Ctrl+Alt+R

- [x] recommended: Add Caelestia focused-monitor recording, without audio.
- [ ] Do not add this binding.
- [ ] other:

### 22. Super+Alt+R

- [x] recommended: Add Caelestia focused-monitor recording with output audio.
- [ ] Do not add this binding.
- [ ] other:

### 23. Super+Shift+Alt+R

- [ ] recommended: Add Caelestia selected-region recording without audio.
- [ ] Add selected-region recording with output audio.
- [x] Do not add this binding.
- [ ] other:

## Neovim-inspired search

Neovim normal-mode Ctrl+P opens project files. Apostrophe is the leader:
`'<Space>` lists buffers, `'pr` lists recent files, and `'pg` runs live grep.
The desktop should not intercept plain Ctrl+P.

### 24. Desktop file picker

Caelestia's existing launcher is not a general filesystem picker. This requires
a separate implementation and a deliberately scoped search root.

- [ ] recommended: Defer to a second pass; preserve Ctrl+P in applications and Super+P pseudotile.
- [ ] Add Super+Ctrl+P for a file picker, searching the home directory while excluding hidden/cache and dependency directories by default.
- [ ] Add Super+Ctrl+P for a file picker, but decide search roots and opening behaviour before implementation.
- [x] other: Super+P for file picker, offer alternative for pseudotile and explination of what it is

### 25. Running-window picker

This is conceptually like Neovim's open-buffer picker, not the application
launcher. It requires a separate running-window selection implementation.

- [ ] recommended: Defer to a second pass; preserve Super+D application launcher and Super+Tab current/previous window.
- [x] Add Super+Space for a searchable running-window picker; preserve the existing launcher and window toggle.
- [ ] Add Super+Space as another Caelestia application-launcher shortcut instead.
- [ ] other:

### 25a. Recent-file picker

Desktop counterpart to Neovim's `'pr`. Desktop recent-file records are separate
from Neovim's history and may include sensitive filenames.

- [ ] recommended: If adding desktop pickers, use Super+Ctrl+R for recently opened files; respect desktop recent-file/privacy settings and do not enable new tracking automatically.
- [x] Defer recent-file search; implement only the file/window pickers selected above.
- [ ] other:

### 25b. File-content search

Desktop counterpart to Neovim's `'pg` live grep. This needs a scoped search and
a way to open a selected text file at the matching line.

- [ ] recommended: If adding content search, use Super+Ctrl+G and open results in Neovim inside Kitty; agree search roots first and exclude hidden/cache and dependency directories by default.
- [x] Defer desktop content search; continue using Neovim's existing live grep.
- [ ] other:

### 25c. File-picker opening behaviour

Applies if a general or recent-file picker is selected. Content-search results
can still open at a matching line in Neovim.

- [x] recommended: Use the desktop's default application for general/recent-file selections; do not force PDFs, images, or other non-text files into Neovim.
- [ ] Open text/code files in Neovim inside Kitty and use default applications for other types.
- [ ] Decide opening behaviour before implementing the pickers.
- [ ] other:

### 26. Bare Super launcher

- [ ] recommended: Do not add modifier-release launching; preserve Super+D.
- [x] Add upstream-style launcher opening when Super is pressed and released alone; retain Super+D.
- [ ] other:

## Optional navigation and workspace extensions

### 27. Keyboard resizing

Existing mouse resizing remains available.

- [ ] recommended: Defer new keyboard-resize bindings in this pass.
- [ ] Add Super+Alt+arrows for directional resizing under dwindle.
- [x] Design a resize submap/mode instead of adding always-active chords.
- [ ] other:

### 28. Previous/next workspace

- [x] recommended: Defer additions; preserve numbered workspaces.
- [ ] Add Super+PageUp/PageDown for previous/next workspace.
- [ ] other:

### 29. Workspace groups and silent movement

Upstream uses group-relative numbering and assigns Super+Shift+number to silent
movement. Your current numbering is absolute 1–10 and Shift movement follows
the window.

- [ ] recommended: Preserve current absolute numbering and move-and-follow semantics; do not add workspace groups.
- [ ] Add Super+Alt+number for silent movement while preserving existing Super+Shift+number behaviour.
- [ ] Design workspace groups separately before implementation.
- [x] other: Give further explination of what this means, what group-relative is, how it relates to multiple monitors and number assignment

### 30. Window grouping

Upstream Alt+Tab cycles within a window group; it is not a conventional
all-window switcher.

- [x] recommended: Defer grouped-window shortcuts.
- [ ] Add upstream grouping shortcuts after a separate workflow review.
- [ ] other:

### 31. Special application workspaces

Upstream music/chat/sidebar bindings collide with your navigation/launcher.
The defaults also assume applications such as Foot, Spotify, and Todoist.

- [x] recommended: Do not add automatic music/chat/todo/system-monitor workspace workflows yet.
- [ ] Design special workspaces separately, specifying applications and nonconflicting keys.
- [ ] other:

## Clipboard, media, power, and service management

### 32. Clipboard history

A shortcut alone does not start collection. Persistent history can contain
sensitive data; retention and password-manager handling require review.
Super+V is already toggle floating.

- [x] recommended: Leave persistent clipboard collection and shortcuts off for this pass.
- [ ] Add opt-in clipboard history on Super+Ctrl+V, but review collection, retention, and sensitive-content handling before implementation.
- [ ] other:

### 33. Automatic paste of latest history entry

- [x] recommended: Do not add upstream's automatic paste-latest shortcut.
- [ ] Review a paste-latest shortcut separately before implementation.
- [ ] other:

### 34. Media playback keys

Changing the backend may change which player receives the action.

- [ ] recommended: Keep existing hardware key chords but use Caelestia's media actions to match the shell-selected player.
- [x] Keep the current playerctl actions unchanged.
- [ ] Also add upstream Ctrl+Super+Space play/pause and Ctrl+Super+Equal/Minus next/previous aliases.
- [ ] other:

### 35. Volume, mute, and brightness

- [ ] recommended: Preserve current volume/mute actions, 5% increments, locked/repeating behaviour, and Ruby-only brightness bindings.
- [ ] Review Caelestia brightness/media integration and external-monitor support separately.
- [ ] other:

### 36. Sleep and lock recovery

Sentry deliberately disables suspend. Do not bypass that policy.

- [ ] recommended: Preserve Super+L lock; do not add upstream sleep or lock-recovery shortcuts in this pass.
- [ ] Add a sleep shortcut only on hosts allowing suspend; decide the chord and lock-before-sleep behaviour first.
- [x] other: Do recommended but also add the lock-recovery shortcuts if possible as the system may still fall asleep on lock and I'm stuck, (at least at a note in readme to do to fix)

### 37. Shell restart/kill shortcuts

Your shell is systemd-managed; upstream's daemon-management shortcuts should
not be copied blindly.

- [x] recommended: Do not add restart/kill bindings in this pass; retain systemd ownership.
- [ ] Add a shortcut for systemctl --user restart caelestia.service, without adding a shell-kill shortcut; specify the chord under other.
- [ ] other:

## Implementation and rollout

### 38. Validation and deployment

- [x] recommended: Implement selected decisions, evaluate both graphical hosts, and review the diff; do not rebuild or switch live hosts until separately approved.
- [ ] Implement and validate selected decisions, then rebuild/switch Sentry only.
- [ ] Implement and validate selected decisions, then rebuild/switch both graphical hosts.
- [ ] other:

### 39. Temporary review file

- [ ] recommended: Keep this file uncommitted until implementation is accepted, then remove it.
- [x] Keep it uncommitted as a temporary checklist after implementation.
- [ ] other:

## Additional notes

other: Anything not done within here or defered should be tracked, either in here or elsewhere. Add to the readme todo 'keybindings and check a first pass on it, with second pass to come'. Additionally, it would be nice to have a way to review the set keybinds, either in a picture in wallpapers that gets generated, or a keybindings file for caelestia that is extremely readable for reference. Ideally if I'm using my computer and I want to check a keybind, I can use this reference without interrupting what I'm doing too bad. add a keybind to display this reference.

## Implementation follow-up (temporary)

### Clarifications approved in conversation

- Remove Super+D; launch applications by pressing/releasing Super alone.
- Super+Q closes; Super+C clears notifications; Super+Shift+C picks a colour.
- Super+P selects files from home, excluding hidden/cache/dependency directories;
  desktop default applications open selections. Super+Shift+P toggles pseudotile.
- Screenshot organization reminder: check on login and additional screenshots,
  at 50 or more images. No periodic timer, automatic removal, or relocation.
- Super+R enters dwindle resize mode; M/N/E/I and arrows resize;
  Escape/Enter exits. Super+? opens the searchable read-only binding reference.
- Preserve absolute workspace numbering and move-and-follow behaviour.
  Workspace groups are an experiment for a later pass, not approved changes.
- Black/unresponsive lock screen: add authenticated TTY recovery instructions,
  not an authentication-bypass shortcut or unmanaged shell restart.

### First-pass implementation

- [x] Add shared Caelestia binding module without changing Windows/WSL hosts.
- [x] Preserve symbolic navigation, Ruby layout switching, media/volume/brightness
  behaviour, lock, compositor exit, interactive Alt+F4, and workspace semantics.
- [x] Add selected screenshot, recording, picker, colour, shell and resize actions.
- [x] Remove redundant broken Super+A because Print remains area selection.
- [x] Generate `~/.config/caelestia/keybindings.txt` from effective bindings;
  show it in a searchable Fuzzel overlay on Super+?.
- [x] Add README first-/second-pass TODO and black-screen recovery instructions.
- [x] Unit-test helper cancellation, dismissal, saving, concurrent filenames,
  cleanup, reminders, picker cancellation and exact path/window targeting.
- [x] Evaluate both hosts' effective Home Manager settings and rendered Hyprland
  configuration. NixOS/Home Manager assertions pass; Sentry has 84 distinct
  chords and Ruby 86, including 10 resize-mode chords each. The only host chord
  differences are Ruby's two existing brightness keys. Pinned globals verified.
- [x] Run all 12 helper tests; build both generated reference files; check Nix
  formatting and diff whitespace. Sentry suspend prohibition and Ruby's
  symbol-based layout switching are preserved.
- [ ] Deploy only after separate approval; no rebuild/switch or commit authorized.
- [ ] After deployment, run `hyprctl binds`, `devices`, `globalshortcuts`, and
  `configerrors` on both hosts. SSH from Sage timed out for both hosts during review.
- [ ] Test bare left/right Super, both key-release orders, unbound Super chords,
  modifiers, mouse dragging, fullscreen behaviour, and no launcher after chords.
- [ ] Test Super+? on Sentry's Voyager and Ruby in both configured layouts.
  Sentry's firmware layout is still unverified.
- [ ] Test copy/paste, notification Save/dismissal, simultaneous captures, Swappy,
  monitor Open/Save, frozen capture, recording toggle and output audio.
- [ ] Confirm reminder at login/50+ images, folder-change notification replacement,
  and actual XDG Pictures storage on both hosts.
- [ ] Test file/window pickers and resize mode with real applications/monitors.
- [ ] Diagnose black-screen recovery if it recurs; do not bypass Sentry's
  suspend policy or introduce unauthenticated unlock shortcuts.

### Deferred / intentionally not enabled

- Scrolling/master navigation redesign (§4); resizing additions are dwindle-only.
- Recent-file search and tracking (§25a), desktop content search (§25b).
- Previous/next workspace shortcuts (§28); workspace groups and multi-monitor
  numbering experiments (§29); grouped-window shortcuts (§30).
- Automatic special-application workspace workflows (§31).
- Persistent clipboard collection/history (§32) and automatic paste (§33).
- Media backend changes (§34); volume/brightness redesign (§35 was unchecked).
- Region-recording shortcut (§23), suspend shortcuts (§36), shell kill/restart
  shortcuts (§37). These are off, not implicit future implementation approvals.

### Pinned-tool limitations to review during runtime testing

- New implementation files remain untracked, as does this checklist. Evaluation
  used `path:.` so those files are included without staging or committing.
  A later Git-flake deployment must include the new implementation files.
- No full host or helper-package build was performed. A helper build dry-run
  resolved the pinned CLI and dependencies but would download about 235 MiB;
  Python tests and Nix/reference evaluation/builds were used for this pass.
- Native Caelestia monitor screenshots retain their native Open/Save actions.
  The pinned CLI uses second-resolution cache names; the wrapper rejects a
  second monitor capture until the previous notification interaction ends.
- Native frozen clipboard capture has no notification Save action, as selected.
- Native Swappy saves retain Swappy's filename semantics; the new area helper
  instead uses collision-safe unique names and removes its temporary image
  when the notification is dismissed.

### Later simplification requested in conversation

- Super+P now opens the existing Yazi file browser directly in Kitty at home,
  rather than implementing a separate filesystem picker. Yazi's normal
  browsing/opening behaviour replaces the earlier scoped-picker design.
  `FILE_BROWSER` defaults to `yazi`; Hyprland's `$fileBrowser` uses that configured
  value rather than hardcoding Yazi in the binding.
- Super+? calls Fuzzel directly to display the generated reference; selecting a
  line does not execute anything.
- Removed Python file-picker/reference actions and the helper's explicit fd and
  xdg-utils dependencies. Remaining helper logic is limited to screenshots,
  screenshot organization reminders, and searchable running-window selection.
- The obsolete file-picker test was removed; the remaining helper suite has 11
  tests. Runtime checks above still apply, using Yazi for Super+P.
- Screenshot reminders were subsequently moved out of Python into the standalone
  `screenshot-reminder` script defined in `_screenshot-reminder.nix`. Login and
  directory-change checks call it directly; capture helpers no longer trigger
  redundant checks. It stores only a count/notification ID and never deletes images.
- The remaining Python suite has 10 tests. The reminder script was built and
  separately tested with stubbed notifications: 50-image threshold, newline
  filenames, image filtering, unchanged-count deduplication, login reminders,
  notification replacement, concurrent-check locking and temporary-state cleanup.
- The generic `desktop-tools` dispatcher was subsequently removed entirely:
  - `area-screenshot.py`: region capture/copy/optional Save; packaged as
    `area-screenshot`, with seven standalone unit tests.
  - `_monitor-screenshot.nix`: small shell wrapper around native Caelestia capture,
    using `flock --close` so clipboard/notification children cannot retain its lock.
  - `_window-picker.nix`: independent Python window picker embedded in Nix,
    with four tests against its built executable.
  - `_screenshot-reminder.nix`: remains an independent Nix-defined shell script.
- Area/window packages were built; all 11 unit tests pass. The monitor wrapper
  was built with a stub CLI and tested for invocation, busy-lock handling, lock
  release and error propagation. Both host evaluations/assertions pass and
  default-map chords remain unique (74 Sentry / 76 Ruby).
- `FILE_BROWSER` is now the only file-browser setting. The redundant Hyprland
  `$fileBrowser` alias was removed; Nix inserts the configured value into the
  Super+P command. It still defaults to Yazi running inside Kitty.
- Window-picker logic was subsequently moved from `_window-picker.nix` into
  standalone `window-picker.py`. The redundant Nix helper file was removed;
  only the executable/dependency packaging remains in `keybindings.nix`.
  Its four tests now run directly against the Python source without a package
  build or executable-path argument.
- The remaining underscore-prefixed Nix helpers were subsequently converted to
  flake-parts modules registering named Home Manager modules:
  `screenshot-reminder.nix`, `monitor-screenshot.nix`, and
  `keybinding-reference.nix`. Caelestia imports them via
  `self.modules.homeManager`, without direct helper-file imports.
- The reminder now owns its package, login check, service and folder watcher;
  none of that lives in `keybindings.nix`. Shared screenshot storage/settings
  live in Caelestia's default module.
- Lock, media, repeating/locked volume/mute, and conditional Ruby brightness
  bindings were consolidated into `keybindings.nix`.
- Both host evaluations/assertions and all 11 unit tests pass after the module
  conversion. Package store paths, reference output, storage configuration and
  reminder units are unchanged. Bindings are unchanged apart from invoking
  the same installed `monitor-screenshot` package by executable name.
