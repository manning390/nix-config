{
    flake.aspects.nvim = {
        homeManager = {inputs, ...}: {
            imports = [inputs.nvf.homeManagerModules.default];
            programs.nvf = {
                enable = false;
                settings = {
                    vim.viAlias = true;
                    vim.vimAlias = true;
                    vim.lsp = {
                        enable = true;
                    };
                    vim.clipboard = {
                        enable = true;
                        providers = {
                            wl-copy.enable = true;
                        };
                    };
                };
            };
        };
    };
}
