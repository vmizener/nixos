local M = {}
M.ALL = {
    'enable_config',
}
M.CONFIGS = {
    -- Lua (lua_ls) {{{
    lua_ls = {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if (path ~= vim.fn.stdpath('config')) and (
                        vim.uv.fs_stat(path .. '/.luarc.json')
                        or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                diagnostics = {globals = {'vim'}},
                runtime = {
                    -- Tell the language server which version of Lua you're using (most
                    -- likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                    -- Tell the language server how to find Lua modules same way as Neovim
                    -- (see `:h lua-module-load`)
                    path = {
                        'lua/?.lua',
                        'lua/?/init.lua',
                    },
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,         -- Neovim runtime files
                        vim.fn.stdpath('config'),   -- User config files
                        '${3rd}/luv/library',       -- LibUV C library (adds `vim.uv`)
                        -- Depending on the usage, you might want to add additional paths
                        -- here.
                        -- '${3rd}/busted/library',
                    },
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = vim.api.nvim_get_runtime_file('', true),
                },
            })
        end,
        settings = {
        },
    },
    -- }}}
    -- Nix (nixd) {{{
    nixd = {
        settings = {
            nixd = {
                nixpkgs = {
                    expr = "import <nixpkgs> { }",
                },
                formatting = {
                    command = { "nixfmt" },
                },
                options = {
                    nixos = {
                        expr = '(builtins.getFlake("git+file://" + toString ./.)).nixosConfigurations.baohaus.options',
                    },
                    home_manager = {
                        expr = '(builtins.getFlake("git+file://" + toString ./.)).nixosConfigurations."bao@baohaus".options',
                    },
                },
            },
        },
    }
    -- }}}
}

function M.enable_config(name, config)
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
end

function M.init()
    for name, config in pairs(M.CONFIGS) do
        M.enable_config(name, config)
    end
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = require('mappings').lsp_attach
    })
end

return M
-- vim: set foldmethod=marker foldlevel=0 :
