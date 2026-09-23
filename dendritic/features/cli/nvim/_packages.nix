{pkgs}:
with pkgs; [
  devenv
  ripgrep
  nodejs

  # LSP
  tree-sitter
  lua-language-server
  unstable.svelte-language-server
  neovim-node-client
  typescript
  typescript-language-server
  eslint
  eslint_d
  emmet-language-server
  efm-langserver
  nixd
  vale-ls
  vscode-langservers-extracted
  tailwindcss-language-server

  # Formatter
  stylua
  codespell
  prettierd
  fixjson

  # dotnet
  (with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_10_0
    ])
  dotnet-ef
  csharpier
]
