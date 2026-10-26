# Neovim: Nix packages, Lua configuration, lze loading

## Layout

- `default.nix`: Home Manager integration, external source inputs, and parser paths.
- `_plugins.nix`: installed plugins, native builds, and optional/start packages.
- `_packages.nix`: language servers, formatters, and other executables.
- `lua/plugins/init.lua`: combines the grouped specs and calls `lze.load` once.
- `lua/plugins/{ui,editing,lsp,completion,telescope,tools}.lua`: loading triggers
  and setup hooks. Names match Nix's installed package directory, not GitHub URLs.
- `lua/config/`: editor settings, mappings, and larger plugin configurations.
- `snippets/`: LuaSnip snippets.

There is no lazy.nvim bootstrap, runtime plugin installation, or lazy-lock file.
The former `after/plugin` files are modules invoked from the relevant lze hooks.
Disabled Lazy specs (Laravel, Trouble, nvim-test, Twilight, Obsidian, and the local
wrd experiment) remain uninstalled. Some old mappings still reference disabled
experiments (for example, `:TestNearest` and `:Wrd`), as before the migration.

## Adding a plugin

1. Add its nixpkgs derivation to `_plugins.nix`, usually in the optional list.
2. Add a spec to the appropriate `lua/plugins/` group:

   ```lua
   {
       "plugin.nvim",
       cmd = "PluginCommand", -- or ft, event, keys, on_require
       after = function()
           require("plugin").setup({})
       end,
   }
   ```

3. For plugins absent from nixpkgs, add a `flake = false` source through
   `externalPlugins` in `default.nix`, declare its dependencies in `_plugins.nix`,
   and run `nix run .#write-flake`. No upstream flake is necessary.
4. Add new files to Git so flake builds can see them, then rebuild Home Manager
   or the host configuration.

`beforeAll` runs at registration (Lazy's `init`); `after` runs after loading
(Lazy's `config`). Setup calls are explicit instead of inferred from `opts`.
`DeferredUIEnter` replaces `VeryLazy`. `dep_of` loads before another plugin;
`on_plugin` loads after it, before its configuration hook.

## Loading details

- Theme, statusline, Harpoon, LSP registration, and mapping-providing Vim plugins
  load at startup intentionally.
- Telescope, formatting, snippets, Treesj, DAP, and Overseer load when required
  or invoked. Keymaps defer `require` calls until use.
- Completion loads on `InsertEnter`; its source plugins explicitly source their
  `after` directories, which plain `packadd` does not do after startup.
- Treesitter parsers and native plugin builds come from Nix; Lua never builds or
  updates them. The existing Svelte parser patch is retained.
- LuaRocks-backed plugins use the nightly editor's LuaJIT package set to avoid
  mixing incompatible Lua dependency environments.

## Updating

Update the nixpkgs input supplying `pkgs.vimPlugins` (currently `nixpkgs` for the
NixOS hosts), or individual external inputs, then rebuild:

```sh
nix flake update nixpkgs
nix flake update telescope-heading
```

The nightly editor and its LuaRocks-backed plugin sources/dependencies follow
`nixpkgs-unstable` through the nightly input. External inputs retain their own
locked revisions. No `:Lazy update` equivalent is needed.

Language tools may still have their own runtime requirements: in particular,
easy-dotnet's server/debugger provisioning is upstream behavior, separate from
installing the Neovim plugin. Migrating the loader does not package those servers.

## Smoke test

After rebuilding, run from this directory:

```sh
nvim --headless '+luafile tests/smoke.lua'
```

This checks startup registration, deferred loading, Telescope extensions,
completion sources, and parser availability. It does not start language servers,
debug adapters, browser preview servers, or the easy-dotnet backend.
