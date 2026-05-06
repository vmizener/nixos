local M = {}

M.ALL = {
  "enable_config",
}
M.CONFIGS = {
  -- Lua (lua_ls) {{{
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          (path ~= vim.fn.stdpath("config"))
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        diagnostics = { globals = { "vim" } },
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME, -- Neovim runtime files
            vim.fn.stdpath("config"), -- User config files
            "${3rd}/luv/library", -- LibUV C library (adds `vim.uv`)
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
    settings = {},
  },
  -- }}}
  -- Nix (nixd) {{{
  nixd = {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
    settings = {
      nixd = {
        nixpkgs = {
          expr = "import <nixpkgs> { }",
        },
        formatting = {
          command = { "nixfmt" },
        },
        options = (function()
          local is_nixos = vim.env["IS_NIXOS"] == "true"
          local username = vim.env["USER"]
          local hostname = vim.system({ "uname", "-n" }, { text = true }):wait()["stdout"]:gsub("\n", "")
          local flake_expr = '(builtins.getFlake("' .. vim.env["NH_FLAKE"] .. '"))'
          if is_nixos then
            return {
              nixos = {
                expr = table.concat({
                  flake_expr,
                  "nixosConfigurations",
                  hostname,
                  "options",
                }, "."),
              },
              home_manager = {
                expr = table.concat({
                  flake_expr,
                  "nixosConfigurations",
                  hostname,
                  "options.home-manager.users.type.getSubOptions []",
                }, "."),
              },
            }
          else
            return {
              home_manager = {
                expr = table.concat({
                  flake_expr,
                  "homeConfigurations",
                  '"' .. username .. "@" .. hostname .. '"',
                  "options",
                }, "."),
              },
            }
          end
        end)(),
      },
    },
  },
  -- }}}
}

function M.enable_config(name, config)
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

function M.init()
  -- Enable global settings
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })
  vim.diagnostic.config({ virtual_lines = true })
  -- Enable per-server settings
  for name, config in pairs(M.CONFIGS) do
    M.enable_config(name, config)
  end
  -- Add autocmd to trigger settings when a server attaches
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      -- Bind LSP mappings
      require("mappings").lsp_attach(ev)
      -- Enable completion if supported
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client:supports_method("textDocument/completion") then
        vim.opt.completeopt = { "menuone", "preview", "noselect", "fuzzy" }
        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      end
    end,
  })
end

return M
-- vim: set foldmethod=marker foldlevel=0 :
