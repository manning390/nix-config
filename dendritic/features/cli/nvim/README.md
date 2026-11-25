# Neovim: plugin declarations in flake modules

## Layout and consumption

- `plugins/*.nix` are flake-parts modules, discovered by `import-tree`.
  They contribute `local.nvim.plugins.<name>` records and, when needed, `flake-file.inputs`.
  They do not import a per-plugin helper.
  Closely related plugins share a modules, see `treesitter.nix` & `telescope.nix`
  Each plugin keeps its own record and can still be disabled independently.
- `options.nix` exports the shared plugin record options as `modules.flake.nvim-options`.
  `default.nix` imports the exported definition directly to avoid recursively reading `self` during root module collection.
- `_bundle.nix` resolves the records into Home Manager packages, extra executable packages, runtime paths, and one generated Lua spec list.
- `default.nix` wires that bundle into the Neovim Home Manager aspect.
  The generated module is installed as `lua/config/plugin-specs.lua` and is not checked into Git.
- `lua/config/loader.lua` translates explicit `main` + `opts` into setup hooks, then passes all specs to a single `lze.load()` call for cross-plugin ordering.
- `lua/config/` contains editor settings, mappings, and larger configurations.
  Separate Lua configuration files are optional, not a loader requirement.
- `default.nix` lists shared language servers, formatters, and executables alongside the bundle's plugin-specific executable packages.

## A nixpkgs plugin

```nix
{
  local.nvim.plugins.surround = {
    package = "nvim-surround";
    lua = # lua
      ''
        {
          "nvim-surround",
          event = "DeferredUIEnter",
          main = "nvim-surround",
          opts = {},
        }
      '';
  };
}
```

`package` is a `pkgs.vimPlugins` attribute name, or a function from the editor's
plugin package set to a derivation for special cases such as Treesitter.
The Lua name is the installed package directory, not necessarily the Nix name.
Mark all embedded Lua with `# lua` for syntax highlighting.

## An external plugin

Declare the source with the same `flake-file` convention as other modules:

```nix
{
  flake-file.inputs.my-plugin = {
    url = "github:owner/my-plugin";
    flake = false;
  };

  local.nvim.plugins.my-plugin = {
    input = "my-plugin";
    dependencies = pkgs: [pkgs.vimPlugins.plenary-nvim];
    lua = # lua
      ''
        { "my-plugin", cmd = "MyPlugin", main = "my-plugin", opts = {} }
      '';
  };
}
```

Choose exactly one of `package` or `input`. The bundler calls `buildVimPlugin` for
source inputs using their locked revision as the version. Dependencies and source
declarations stay together in the owning plugin/group module. After adding an input, run
`nix run .#write-flake` to regenerate the root flake and lock it.

## Optional record fields

- `enable` defaults to `true`.
  Set `local.nvim.plugins.surround.enable = false;` to omit its package, Lua spec, extra executables, and runtime paths from the
  bundle.
  Source inputs remain declared in `flake-file`, and another plugin may still install the disabled package as a dependency.
  Disabling a plugin does not automatically disable dependent plugins or remove their mappings.
- `enableFor = config: ...` defaults to `_: true` and receives the system configuration (`osConfig`) when creating the Home Manager bundle.
  For example, `enableFor = config: config.networking.hostName == "mado";` restricts a plugin to one host,
  while `enableFor = config: config.wsl.enable or false;` restricts it to WSL.
  Both `enable` and `enableFor` must allow the plugin.
  Flake-level update metadata only checks `enable`, so input updates remain independent of the selected host.
- `optional` defaults to `true`: lze controls loading.
  Use `false` without a Lua spec for shared libraries or plain startup plugins such as `vim-repeat`.
  Native startup scripts run after the editor's init; keep a lze spec when a plugin must load before custom configuration or mappings (Tmux Navigator).
- `dependencies = pkgs: [...]`: adds plugin dependencies to the package recipe.
  Installation dependencies do not replace explicit lze loading relationships.
- `overrideAttrs = old: {...}`: escape hatch for native builds or patches.
- `extraPackages = pkgs: [...]`: executable dependencies, installed by Home Manager.
- `runtimePaths = pkgs: [...]`: additional runtime paths;
  eg. used for Treesitter's Nix-built parsers and grammar parsers patches.

## Lua conventions

- `main` must be explicit when using `opts`; there is no module-name guessing.
- `opts` is a Lua table passed to `require(main).setup(opts)` after loading.
  It has no default: omit it to skip automatic setup, or explicitly use `opts = {}` to call setup with defaults.
  Function-valued opts and Lazy spec merging are deliberately unsupported.
- If `after` is also supplied, it runs **after setup**, receiving the lze plugin.
- Plugins with unusual setup signatures can use a plain `after` instead: Harpoon uses `:setup`, for example.
  `beforeAll` and `before` retain normal lze semantics.
- Specs without lazy-loading triggers load at startup by default.
  They do not need an explicit `lazy = false`; `priority` still orders those startup specs.
- `DeferredUIEnter` replaces `VeryLazy`.
  `dep_of` loads before another plugin;
  `on_plugin` loads after it but before its configuration hook.
- Keymaps defer plugin requires until use.
  Completion sources use the shared `config.loader.with_after` loader to source their `after/plugin` scripts.

## Updates and rebuilding

Neovim has a dedicated `nvim-nixpkgs` input for plugin recipes and editor tools.
The nightly overlay follows it, rather than the shared `nixpkgs-unstable` input.
LuaRocks-backed plugins also use the nightly editor's LuaJIT package set.

From the repository root, inspect or update only Neovim's inputs:

```sh
just nvim-inputs
just update-nvim
```

The input list is generated from enabled plugin records, plus the dedicated nixpkgs and nightly overlay inputs.
There is no manually maintained external plugin list in the updater.
You can evaluate the list directly, without building:

```sh
nix eval --json .#nvim.updateInputs
nix eval --raw .#nvim.updateInputs --apply 'builtins.concatStringsSep " "'
```

The recipe updates `flake.lock` only; rebuild Home Manager/the host afterward.
If you add a new external input, add its module file to Git and run `just flake` first to update the flake.
Shared system nixpkgs pins are not selected by `update-nvim`.
The `nvim-nixpkgs` input is an independent lock node, not a `follows` alias to the system pin.

External sources retain individual locks.
Updating a tag-pinned input (such as PHPActor's `v1.0.1`) does not select a newer tag; change its declared URL first.

Language tools can have separate runtime requirements.
In particular, easy-dotnet still provisions its own server/debugger upstream;
packaging its Neovim plugin does not package that backend.

## Debugging

DAP loads on first use. Its adapters (`js-debug`, `netcoredbg`, and `php-debug`) are installed by the DAP plugin module; rebuild Home Manager/the host to activate changes.
Open Neovim from the project root so `${workspaceFolder}` resolves correctly.

- **TypeScript / Svelte:** start your dev server, open a source file, press `F5`,
  and choose Chrome. Enter the dev server URL (default `http://localhost:5173`).
  Chrome/Chromium must be installed; source maps must be enabled. The Node launch configuration uses Node directly, not `tsx` or `ts-node`;
  use compiled JavaScript or a Node version that supports your TypeScript syntax. For server-side code,
  start Node with `--inspect` and choose Node attach. Do not launch `.svelte` files directly in Node.
- **C#:** run `dotnet build` in Debug configuration, press `F5`, choose .NET launch,
  and select the application's DLL under `bin/Debug/<framework>/`.
  PDB symbols must be available. An attach configuration is also provided.
- **PHP:** enable Xdebug in the PHP runtime that runs the app, with
  `xdebug.mode=debug`, `xdebug.start_with_request=yes`, `xdebug.client_host=127.0.0.1`, and `xdebug.client_port=9003`.
  Press `F5`, choose the PHP listener, then make a web request or run the CLI script.
  Containers/remote hosts need a reachable client host and project-specific `pathMappings` from server paths to local paths.

Project-specific configurations can live in `.vscode/launch.json` (adapter types `pwa-node`, `pwa-chrome`, `coreclr`, and `php`).
These are read on demand.
For custom browser paths, set `runtimeExecutable` in a project configuration.

`<leader>+b` toggles a breakpoint,
`F5` starts/continues, `F10` steps over, `F11` steps into, and `F12` steps out.
`'dh` inspects a value, `'ds` opens scopes, `'dr` toggles the REPL, and `'dt` ends the session.

## Project writing mode

After rebuilding your Nix/Home Manager configuration, put this in a writing
project's `.nvim.lua`:

```lua
require("config.writing").enable({
  language = "en-US", -- or "en-GB"
})
```

Start Neovim from the project root and approve the trust prompt. `exrc` is already
enabled; only trust files you have reviewed, since they can execute arbitrary Lua.
You can also use `:trust` while editing the rc file. Starting from the root works
across supported Neovim versions; ancestor rc discovery depends on Neovim version.
The root is inferred from the rc file, including when chapters live in subdirectories.
For manual Lua calls, `root = "/absolute/project/path"` can override the working directory.

All opened `text` (`.txt`) and `markdown` buffers under that root participate.
Other filetypes and projects are unaffected. No chapters are renamed, rewritten,
or assigned a different filetype. LTeX+ checks `.txt` as plain text, which avoids
assuming your custom markup is standard Markdown. Syntax-specific checking
exclusions are not configured yet; those need examples of the custom syntax.

### Editing and reviewing

- **`'ca`**: your existing LSP code-action binding. At an issue, select a
  correction, **add to dictionary**, **hide false positive**, or **disable rule**.
  Choose **Writing: list buffer issues in quickfix** anywhere in a writing
  buffer to list only that chapter's spelling/grammar issues.
- **`:WritingQuickfix`**: snapshot of grammar/spelling issues from this project's
  opened chapters. Navigate with `:cnext` / `:cprev`, then use `'ca`.
  Run the command again to refresh after fixing issues. It replaces the current
  quickfix list, not lists from other quickfix history entries.
- **`:WritingFocus`**: hide/show writing diagnostics while continuing to check.
- **`:Write off`**, **`on`**, **`toggle`** (or just **`:Write`**): disable, enable, or toggle the
  current project. A manual `on` uses defaults and the current directory; source
  the rc file again to restore its custom options.
- **`:ZenMode`**: independently toggle the existing centered,
  distraction-free layout. Writing mode never enables zen automatically.
- **`:Wrd`**: load your writing tools, now available on all Neovim-configured hosts.

Writing mode uses soft wrapping, word-boundary wraps, display-line movement
(including your Colemak layout), no line numbers, and no automatic hard wrapping
or indentation. Counted vertical movements still operate on real lines.
Buffer settings and mappings are restored on disable; window settings are restored
when leaving writing buffers. LTeX+ is the single spelling source, so native spell
underlines are disabled in writing windows. Conform skips its fallback codespell
and whitespace trimming for writing buffers; nothing is corrected automatically.

### Project dictionaries and ignore rules

Code actions persist immediately in **`.writing/ltex.json`** under the project
root. This contains language-specific dictionaries, disabled rules, and hidden
false positives. Commit it to share accepted names and decisions across chapters
and machines. It is data, not executable Lua.

LTeX's **hide false positive** is sentence/rule-based, not a positional one-off
ignore: another identical matching sentence can also be suppressed. **Disable
rule** affects every chapter in this project. Neither action changes other
projects' dictionaries or rules. To undo an addition/ignore, remove its entry
from the JSON and restart writing mode (or restart Neovim). Malformed JSON is
reported rather than silently overwritten.

Quickfix includes spelling **and** grammar diagnostics from buffers already
checked by LTeX+. It does not crawl unopened chapters. Open the chapters you want
to review, wait for checking, then collect the list. Each project shares one
local LTeX+ process across its chapters; no cloud grammar service is configured.

Advanced server settings can be passed in `ltex = { ... }` alongside `language`
in the rc file. `filetypes = { "text", "markdown" }` controls eligible buffers.
Keep dictionary/rule decisions in `.writing/ltex.json`, which takes precedence
over the corresponding rc settings.

## Tests

From this directory, test the adapter without loading your editor configuration:

```sh
nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/loader.lua'
nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/writing.lua'
```

With `ltex-ls-plus` on `PATH`, test live plain-text diagnostics, code-action
availability, dictionary persistence/rechecking, and applying a suggested edit:

```sh
nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/writing-lsp.lua'
```

After rebuilding, test the complete configured editor:

```sh
nvim --headless '+luafile tests/smoke.lua'
nvim --headless '+luafile tests/bookmarks.lua'
```
