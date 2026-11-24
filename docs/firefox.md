# Firefox

## Managed defaults

[`browsers.nix`](../dendritic/features/desktop/browsers.nix) includes the
[`firefox` aspect](../dendritic/features/desktop/firefox.nix), which contains both
NixOS and Home Manager modules. NixOS owns the package and shared policies;
Home Manager uses that package (`package = null`) and leaves profiles unmanaged
until exports have been reviewed.

These settings apply on hosts including the `browsers` aspect (currently through
`desktop` on `ruby` and `sentry`):

- Disable telemetry, studies, and address-bar search suggestions.
- Disable sponsored new-tab tiles and Pocket content where supported.
- Install uBlock Origin, without removing other extensions.
- Default to strict tracking protection and HTTPS-only mode.
- Default new-tab telemetry to off.

The last two items use preference status `default`: existing explicit user
values take precedence, and settings remain adjustable. Other policies may lock
their corresponding settings. Rebuild the relevant NixOS host and fully restart
Firefox to apply; this does not deploy anything to Windows.

Existing profiles, bookmarks, logins, and extension data are not replaced.
uBlock Origin's extension ID is used, so an existing installation is not
duplicated. Firefox downloads it from Mozilla Add-ons; it is not Nix-pinned.
Other blockers are not removed: review overlapping blockers manually.

## Inspect the current browser

Do this in each profile, not just once per machine:

| Page | What to capture |
| --- | --- |
| `about:profiles` | Profile name, which profile is in use, and its root directory. |
| `about:policies` | Active policies and errors; check this first on a work machine. |
| `about:preferences#privacy` | Tracking protection, HTTPS-only mode, data collection, DNS, and cookie settings. |
| `about:preferences#search` | Default search engine and search suggestions. |
| `about:config` | Effective preference values; search the names below. Bold values indicate modifications, not necessarily who made them. |
| `about:addons` | Installed extensions, enabled state, permissions, and individual options. |
| `about:support` | Firefox version, extensions with IDs/versions, and important modified/locked preferences. “Copy text to clipboard” gives a useful comparison snapshot. |

`about:support` is not a complete preference export. Its modified-preferences
section alone cannot prove that a setting matches: defaults vary by Firefox
version, and some preferences are omitted.

Check these effective values in `about:config`:

| Preference | Intended baseline |
| --- | --- |
| `browser.contentblocking.category` | `strict` |
| `dom.security.https_only_mode` | `true` |
| `browser.search.suggest.enabled` | `false` |
| `browser.urlbar.suggest.searches` | `false` |
| `datareporting.healthreport.uploadEnabled` | `false` |
| `app.shield.optoutstudies.enabled` | `false` |
| `browser.newtabpage.activity-stream.feeds.telemetry` | `false` |
| `browser.newtabpage.activity-stream.telemetry` | `false` |

Also check `about:policies` for the telemetry/studies policies and any errors.
Policy behavior and available preferences can change between Firefox versions.
Never create an absent preference just to make an inventory match.

## Export for review

Use [`scripts/export-firefox.py`](../scripts/export-firefox.py) to export a
selected set of privacy/security preferences and installed extension metadata.
It only reads the profile and writes JSON to standard output. It does not copy
profile data or change Firefox.

1. In the Firefox profile you want to inspect, open `about:support`. Note the
   Firefox version, then use **Profile Folder → Open Folder** to find the root
   directory. This is not the local/cache directory.
2. Exit Firefox fully so that `prefs.js` reflects the latest saved settings.
3. On Sage, run from this repository in WSL, substituting the actual Windows
   profile directory. `wslpath` converts the Windows path:

   ```sh
   python3 scripts/export-firefox.py \
     "$(wslpath 'C:\Users\YOUR_USER\AppData\Roaming\Mozilla\Firefox\Profiles\YOUR_PROFILE')" \
     --label sage/work > ~/firefox-sage-work.json
   ```

   For a Linux host:

   ```sh
   python3 scripts/export-firefox.py \
     /actual/profile/root/from/about-support \
     --label sentry/personal > ~/firefox-sentry-personal.json
   ```

4. Review the JSON before sharing. Internal extension names/IDs can still be
   sensitive. Share the reviewed export together with the Firefox version and
   relevant redacted entries from `about:policies` (Active and Errors).

The export contains `storedPreferences`, missing selected keys in `notStored`,
allowlisted `user.js` preferences if present, and extension IDs, names,
versions, and enabled state. It excludes cookies, history, passwords, URLs,
paths, account data, and arbitrary extension preferences. Extensions' own
settings/filter lists are not included.

**This is not an effective-settings dump.** Firefox defaults and Windows
employer policies are not necessarily stored in `prefs.js`. Missing preferences
mean “unknown,” not “disabled.” Use `about:config` to confirm candidate settings
before translating them into Nix, and respect employer restrictions on exports.
Compare exports from multiple hosts to identify shared preferences and
extensions; no profile synchronization or Windows policy change is needed.

## Sage: Windows work profile

Sage uses Windows Firefox through `wsl-open`; the NixOS Firefox module cannot
manage that browser. `BROWSER_PROFILE` in Sage's environment does not by itself
make `wsl-open` select a Firefox profile.

Use **`sage/work` as an inventory label**, associated with the actual profile
reported by Windows Firefox's `about:profiles`. This is a comparison label,
not a new browser profile, Firefox Sync account, or change to Windows policy.
An existing separate profile can be labeled this way; creating a new one is
not required.

For the work machine:

1. Inspect `about:policies` before making changes. Firefox can receive Windows
   Group Policy or other organization policies that WSL cannot see or override.
2. Record the actual profile name, Firefox version, and only the relevant
   settings/extensions using the template below.
3. Mark employer-required settings/extensions as `work-only` or
   `employer-managed`, not candidates to deploy to personal hosts.
4. Leave Windows policy, the profile directory, certificates, and authentication
   data untouched. Do not use a shared profile directory between Windows and
   Linux, copy the entire work profile, or enable personal Sync on it without
   employer approval.

Firefox profiles separate browser data, but are not an employer-management
bypass or a security boundary against the operating system.

## Compare profiles before sharing settings

Keep raw snapshots outside this repository in an employer-approved location.
`about:support`, preferences, and extension configuration can expose usernames,
paths, internal domains, extension details, and organization information.
Do not commit `prefs.js`, full profile directories, cookies, passwords, session
data, or unreviewed support exports.

For each profile, keep a **sanitized** inventory using this template:

```text
Inventory label: sage/work
Captured on:
OS / Firefox version:
Actual Firefox profile name: [redact if sensitive]
Role: work
Policy source: employer-managed / unmanaged / unknown

Setting or extension ID | Effective value/version | Managed/locked? | Scope
browser.contentblocking.category | ... | ... | shared candidate / work-only
dom.security.https_only_mode | ... | ... | ...
uBlock0@raymondhill.net | version / enabled / absent | ... | ...
```

Repeat for other hosts, e.g. `sentry/personal`. Compare settings by exact
preference name, and extensions by ID rather than display name. Extension
installation does not imply identical extension settings or filter lists;
compare those separately when relevant.

Classify differences as:

- **Shared baseline:** safe, desired across personal profiles; propose changes
  to the `firefox` aspect.
- **Personal-only:** personal accounts, Sync, bookmarks, and extensions.
- **Work-only / employer-managed:** corporate authentication, certificates,
  proxies, internal search, required extensions, or locked settings.
- **Host-specific:** hardware/platform settings or site compatibility exceptions.

Only move reviewed shared choices into Nix. Leave work settings as an inventory
unless explicitly approved for Windows configuration. Sanitized inventories
from other hosts can then be compared against `sage/work` without synchronizing
any private browser data.
