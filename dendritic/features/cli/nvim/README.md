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

## Tests

From this directory, test the adapter without loading your editor configuration:

```sh
nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/loader.lua'
```

After rebuilding, test the complete configured editor:

```sh
nvim --headless '+luafile tests/smoke.lua'
```
